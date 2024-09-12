package cangjieWeb.mysql
import std.database.sql.{Transaction, TransactionAccessMode, TransactionDeferrableMode, TransactionIsoLevel}
public class MySqlTransaction <: Transaction {

    private var _accessMode: TransactionAccessMode = TransactionAccessMode.ReadOnly
    private var _deferrableMode: TransactionDeferrableMode = TransactionDeferrableMode.Deferrable
    private var _isoLevel: TransactionIsoLevel = TransactionIsoLevel.RepeatableRead

    public mut prop accessMode: TransactionAccessMode {
        get() {
            _accessMode
        }
        set(accessMode) {
            _accessMode = accessMode
        }
    }
    public mut prop deferrableMode: TransactionDeferrableMode {
        get() {
            _deferrableMode
        }
        set(deferrableMode) {
            _deferrableMode = deferrableMode
        }
    }
    public mut prop isoLevel: TransactionIsoLevel {
        get() {
            _isoLevel
        }
        set(isoLevel) {
            _isoLevel = isoLevel
        }
    }
    public func begin(): Unit {

    }
    public func commit(): Unit {

    }
    public func release(savePointName: String): Unit{

    }
    public func rollback(): Unit {

    }
    public func rollback(savePointName: String): Unit {

    }
    public func save(savePointName: String): Unit {

    }
}