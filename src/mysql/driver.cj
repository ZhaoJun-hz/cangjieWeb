package cangjieWeb.mysql
import std.database.sql.{Driver, Datasource}
public class MySqlDriver <: Driver {
    public prop name: String {
        get() {
            return "mysql"
        }
    }
    public prop preferredPooling: Bool {
        get() {
            return true
        }
    }
    public prop version: String {
        get() {
             return "0.0.1"
        }
    }
    public func open(connectionString: String, opts: Array<(String, String)>): Datasource {
        return MySqlDatasource()
    }
}