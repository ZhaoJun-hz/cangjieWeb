package cangjieWeb.mysql
import std.database.sql.{Datasource, Connection}
public class MySqlDatasource <: Datasource {
    private let config: Config

    public init(config: Config)  {
        this.config = config
    }

    public func connect(): Connection {
        return MysqlConnection(config)
    }
    public func setOption(key: String, value: String): Unit {

    }
    public func close(): Unit {

    }
    public func isClosed(): Bool {
        return false
    }

}