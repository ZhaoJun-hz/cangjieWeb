package cangjieWeb.mysql
import std.database.sql.{Statement, ColumnInfo, QueryResult, UpdateResult, SqlDbType}
import std.collection.{ArrayList}
public class MySqlStatement <: Statement {
    public prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            return ArrayList<ColumnInfo>().toArray()
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

}