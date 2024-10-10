package cangjieWeb.mysql
import std.database.sql.{Statement, ColumnInfo, QueryResult, UpdateResult, SqlDbType}
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
        return MySqlUpdateResult()
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

}