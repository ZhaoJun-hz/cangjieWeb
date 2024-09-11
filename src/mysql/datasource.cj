package cangjieWeb.mysql
import std.database.sql.{Datasource, Connection}
public class MySqlDatasource <: Datasource {
    public func connect(): Connection {
        return MysqlConnection()
    }
    public func setOption(key: String, value: String): Unit {

    }
    public func close(): Unit {

    }
    public func isClosed(): Bool {
        return false
    }

}