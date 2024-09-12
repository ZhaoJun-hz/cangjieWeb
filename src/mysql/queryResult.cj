package cangjieWeb.mysql
import std.database.sql.{QueryResult, ColumnInfo, SqlDbType}
import std.collection.{ArrayList}
public class MysqlQueryResult <: QueryResult {
    public prop columnInfos: Array<ColumnInfo> {
        get() {
            return ArrayList<ColumnInfo>().toArray()
        }
    }
    
    public func next(values: Array<SqlDbType>): Bool {
        return false
    }
    public func close(): Unit {

    }
    public func isClosed(): Bool {
        return false
    }
}