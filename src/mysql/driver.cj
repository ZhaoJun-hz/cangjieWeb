package cangjieWeb.mysql
import std.database.sql.{Driver, Datasource, DriverManager}
public class MySqlDriver <: Driver {

    static init() {
        println("mysql resister MySqlDriver")
        DriverManager.register("mysql", MySqlDriver())
    }

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
        let config = parseConnectionStringAndParams(connectionString, opts)
        return MySqlDatasource(config)
    }
    // username:password@protocol(address)/dbname
    private func parseConnectionStringAndParams(connectionString: String, opts: Array<(String, String)>): Config {
        let usernameEnd = connectionString.indexOf(":", 0).getOrDefault({ => -1})
        let passwordEnd = connectionString.indexOf("@", 0).getOrDefault({ => -1})
        let protocolEnd = connectionString.indexOf("(", 0).getOrDefault({ => -1})
        let addressEnd = connectionString.indexOf(")", 0).getOrDefault({ => -1})
        let dbnameStart = addressEnd + 2

        let username = connectionString[0..usernameEnd]
        let passwoed = connectionString[usernameEnd + 1 .. passwordEnd]
        let protocol = connectionString[passwordEnd + 1 .. passwordEnd]
        let address = connectionString[protocolEnd + 1 .. addressEnd]
        let dbname = connectionString[dbnameStart ..]
        println("username = {username}, passwoed = ${passwoed}, protocol = ${protocol}, " + 
            "address = ${address}, dbname = ${dbname}"
        )

        let config = Config()
        config.username = username
        config.password = passwoed
        config.protocol = protocol
        config.address = address
        config.dbname = dbname
        for((key, value) in opts) {
            config.params[key] = value
        }

        return config

    }
}