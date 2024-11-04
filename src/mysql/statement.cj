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
    private let _parameters: Array<ColumnInfo> = Array<ColumnInfo>()
    private let _columns: Array<ColumnInfo> = Array<ColumnInfo>()

    private var rowCount: Int64 = 0
    private var lastInsertId: Int64 = 0
    init(connection: MysqlConnection, sql: String) {
        this.connection = connection
        this.sql = sql
        // 发COM_STMT_PREPARE 包
        this.connection.writeCommandPacketStr(comStmtPrepare, sql)
        // 接COM_STMT_PREPARE_OK
        readPrepareResultPacket()
    }

    public prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            return _parameters
        }
    }
    public func query(params: Array<SqlDbType>): QueryResult {
        return MysqlQueryResult()
    }
    public func setOption(key: String, value: String): Unit {

    }
    public func update(params: Array<SqlDbType>): UpdateResult {

        // 发送 
        writeExecutePacket(params)

        // 拿结果
        readRequstSetHeaderPacket()
        return MySqlUpdateResult(rowCount, lastInsertId)
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

        id = ByteArrayUtils.littleEndianUint32(data[1..5])
        columnCount = ByteArrayUtils.littleEndianUint16(data[5..7])
        paramCount = ByteArrayUtils.littleEndianUint16(data[7..9])
        if (paramCount > 0) {
            let params:ArrayList<MySqlField> = this.connection.readColumns(paramCount)
        }
        if (columnCount > 0) {
            let columns:ArrayList<MySqlField> =  this.connection.readColumns(columnCount)
        }
    }


    private func writeExecutePacket(params: Array<SqlDbType>) {
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
            let param = params.get(i).getOrThrow()
            match(param.name) {
                case "SqlNullableBigInt" => 
                    let temp = param as SqlNullableBigInt
                    let value = temp.getOrThrow()
                    match (value.value) {
                        case Some(number) => 
                            paramTypes[i<<1] = fieldTypeLongLong
                            let appendValue = ByteArrayUtils.uint64ToBytes(UInt64(number))
                            paramValues.append(appendValue)
                            pktLen += 8
                        case None => 
                            bitMask += 1 << UInt64(i)
                            paramTypes[i<<1] = fieldTypeNULL
                            paramValues.append(Array<Byte>())
                    }

                case "SqlBigInt" => 
                    let temp = param as SqlBigInt
                    let value = temp.getOrThrow().value
                    paramTypes[i<<1] = fieldTypeLongLong
                    let appendValue = ByteArrayUtils.uint64ToBytes(UInt64(value))
                    paramValues.append(appendValue)
                    pktLen += 8

                case "SqlNullableInteger" => 
                    let temp = param as SqlNullableInteger
                    let value = temp.getOrThrow()
                    match (value.value) {
                        case Some(number) => 
                            paramTypes[i<<1] = fieldTypeLong
                            let appendValue = ByteArrayUtils.uint32ToBytes(UInt32(number))
                            paramValues.append(appendValue)
                            pktLen += 4
                        case None => 
                            bitMask += 1 << UInt64(i)
                            paramTypes[i<<1] = fieldTypeNULL
                            paramValues.append(Array<Byte>())
                    }

                case "SqlInteger" => 
                    let temp = param as SqlInteger
                    let value = temp.getOrThrow().value
                    paramTypes[i<<1] = fieldTypeLong
                    let appendValue = ByteArrayUtils.uint32ToBytes(UInt32(value))
                    paramValues.append(appendValue)
                    pktLen += 4

                case "SqlVarchar" =>
                    let temp = param as SqlVarchar
                    let value = temp.getOrThrow().value
                    
                    paramTypes[i<<1] = fieldTypeVarString
                    let result = ArrayList<Byte>()

                    var lengthBytes = ByteArrayUtils.appendLengthEncodedInteger(UInt64(value.toArray().size))
                    result.appendAll(lengthBytes)
                    result.appendAll(value.toArray())
                    paramValues.append(result.toArray())
                    pktLen = pktLen + result.toArray().size

                case _ => println("unsupport data type")
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