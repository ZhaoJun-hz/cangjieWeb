package cangjieWeb.mysql
import std.database.sql.{Connection, ConnectionState, Transaction, Statement}
import std.collection.{Map,HashMap}
public class MysqlConnection <: Connection {
    public prop state: ConnectionState {
        get() {
            return ConnectionState.Connected
        }
    }
    public func createTransaction(): Transaction {
        return MySqlTransaction()
    }
    public func getMetaData(): Map<String, String> {
        HashMap([])
    }
    public func prepareStatement(sql: String): Statement {
        return MySqlStatement()
    }
    public func close(): Unit {

    }
    public func isClosed(): Bool {
        return false
    }
}