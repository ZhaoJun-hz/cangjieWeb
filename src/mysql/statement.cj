package cangjieWeb.mysql
import std.database.sql.*
import std.collection.{ArrayList}
import cangjieWeb.utils.ByteArrayUtils
public class MySqlStatement <: Statement {

    private let connection: MysqlConnection
    private let sql: String
    private var id: UInt32 = 0
    private var columnCount: UInt16 = 0
    private var paramCount: UInt16 = 0
    private var _parametersInfo: Array<ColumnInfo> = Array<ColumnInfo>()
    private var _columns: Array<ColumnInfo> = Array<ColumnInfo>()

    private var parameters: Array<Any> = Array<Any>()

    private var rowCount: Int64 = 0
    private var lastInsertId: Int64 = 0
    init(connection: MysqlConnection, sql: String) {
        this.connection = connection
        this.sql = sql
        // 发COM_STMT_PREPARE 包
        this.connection.writeCommandPacketStr(comStmtPrepare, sql)
        // 接COM_STMT_PREPARE_OK
        readPrepareResultPacket()
        this.parameters = Array<Any>(Int64(this.paramCount), repeat: Option<Any>.None)
    }

    public prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            return _parametersInfo
        }
    }

    public func set<T>(index: Int, value: T): Unit {
        parameters[index - 1] = value
    }

    public func setNull(index: Int): Unit {
        parameters[index - 1] = Option<Any>.None
    }

    public func query(): QueryResult {
        writeExecutePacket(parameters)
        // 拿结果
        let columnNumber = readRequstSetHeaderPacket()

        var columns: ArrayList<ColumnInfo> = ArrayList<ColumnInfo>()
        var rows: ArrayList<Array<Byte>> = ArrayList<Array<Byte>>()

        if (columnNumber > 0) {
            // columns 列定义信息
            columns = this.connection.readColumns(UInt16(columnNumber))
            // rows
            rows = this.connection.readRows()
        }
        return MysqlQueryResult(columns, rows)
    }

    public func update(): UpdateResult {
        // 发送 
        writeExecutePacket(parameters)
        // 拿结果
        readRequstSetHeaderPacket()
        this.parameters = Array<Any>(Int64(this.paramCount), repeat: Option<Any>.None)
        return MySqlUpdateResult(rowCount, lastInsertId)
    }

    @Deprecated
    public func query(params: Array<SqlDbType>): QueryResult {
       throw Exception("Deprecated method")
    }
    public func setOption(key: String, value: String): Unit {

    }

    @Deprecated
    public func update(params: Array<SqlDbType>): UpdateResult {
        throw Exception("Deprecated method")
    }

    public func close(): Unit {

    }
    public func isClosed(): Bool {
        return false
    }

    private func readPrepareResultPacket() {
        let data = this.connection.readPacket()
        if (data[0] != iOK) {
            println("error here, do later")
        }

        this.id = ByteArrayUtils.littleEndianUint32(data[1..5])
        this.columnCount = ByteArrayUtils.littleEndianUint16(data[5..7])
        this.paramCount = ByteArrayUtils.littleEndianUint16(data[7..9])
        if (paramCount > 0) {
            this._parametersInfo = this.connection.readColumns(paramCount).toArray()
        }
        if (columnCount > 0) {
            this._columns =  this.connection.readColumns(columnCount).toArray()
        }
    }


    private func writeExecutePacket(params: Array<Any>) {
        connection.sequence = 0
        // status 1
        // statement_id 4
        // flags 1
        // iteration_count 4
        // null_bitmap (paramater_count + 7) / 8
        // new_params_bind_flag 1
        // parameter_type paramCount * 2

        var pktLen = 1 + 4 + 1 + 4 + (Int64(paramCount) + 7) / 8 + 1 + Int64(paramCount) * 2
        let paramValues = ArrayList<Array<Byte>>()
        let paramTypes = Array<Byte>(Int64(paramCount) * 2, repeat : 0)
        var bitMask = UInt64(0)

        for (i in 0 .. params.size) {
            
            match(params[i]) {
                case v: Int64 => 
                    paramTypes[i<<1] = fieldTypeLongLong
                    let appendValue = ByteArrayUtils.uint64ToBytes(UInt64(v))
                    paramValues.add(appendValue)
                    pktLen += 8
                case v: Int32 =>
                    paramTypes[i<<1] = fieldTypeLong
                    let appendValue = ByteArrayUtils.uint32ToBytes(UInt32(v))
                    paramValues.add(appendValue)
                    pktLen += 4
                case v: String =>
                    paramTypes[i<<1] = fieldTypeVarString
                    let result = ArrayList<Byte>()

                    var lengthBytes = ByteArrayUtils.appendLengthEncodedInteger(UInt64(v.toArray().size))
                    result.add(all: lengthBytes)
                    result.add(all: v.toArray())
                    paramValues.add(result.toArray())
                    pktLen = pktLen + result.toArray().size
                case v: ?Any => 
                    if(v.isNone()) {
                        bitMask += 1 << UInt64(i)
                        paramTypes[i<<1] = fieldTypeNULL
                        paramValues.add(Array<Byte>())
                    }
                case _ => throw Exception("unsupport type")
            }
        }

        // 包的长度计算好了
        // bitMask => null_bitmap
        // paramTypes  parameter_type
        // paramValues  参数的值

        let data = Array<Byte>(pktLen + 4, repeat: UInt8(0))

        // status
        data[4] = comStmtExecute

        // statement_id
        data[5] = UInt8(id)
        data[6] = UInt8(id >> 8)
        data[7] = UInt8(id >> 16)
        data[8] = UInt8(id >> 24)
        // data[9] flags 0 
        // iteration_count 4 
        data[10] = 0x01

        if (paramCount > 0) {
            // null_bitmap 结束下标
            var pos = 14 + ((Int64(paramCount) + 7) / 8)
            for (i in 14 .. pos) {
                data[i] = UInt8(bitMask >> UInt64((i - 14) * 8))
            }
            // null_bitmap 填充好了
            // new_params_bind_flag
            data[pos] = 0x01
            pos ++

            // parameter_type
            paramTypes.copyTo(data, 0, pos, paramTypes.size)
            pos += paramTypes.size

            // params value
            for(i in 0 .. paramCount) {
                let paramValue = paramValues[Int64(i)]
                paramValue.copyTo(data, 0, pos, paramValue.toArray().size)
                pos += paramValue.toArray().size
            }
        }
        
        // 包已经准备好了

        connection.writePacket(data)
    }

    private func readRequstSetHeaderPacket(): Int64 {
        let data = connection.readPacket()

        match(data[0]) {
            case 0 =>
                // OK_Packet  affected_rows  last_insert_id
                handleOkPacket(data[1..])
                return 0

            case 255 =>
                // ERR_Packet
                print("err here, do later")
                return -1

            case _ =>
                // Binary Protocol Resultset
                let (number, isNull, n) = ByteArrayUtils.readLengthEncodeInteger(data)
                // 返回  column_count
                return Int64(number)
        }
    
    }

    private func handleOkPacket(data: Array<Byte>) {
        let (affectedRows, affectedRowsIsNull, n) = ByteArrayUtils.readLengthEncodeInteger(data)
        let (insertId, insertIdIsNull, m) = ByteArrayUtils.readLengthEncodeInteger(data[n..])
        rowCount = Int64(affectedRows)
        lastInsertId = Int64(insertId)
    }
}