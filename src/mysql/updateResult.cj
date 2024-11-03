package cangjieWeb.mysql
import std.database.sql.{UpdateResult}
public class MySqlUpdateResult <: UpdateResult {

    private var _rowCount: Int64
    private var _lastInserId: Int64

    public init(rowCount:Int64, lastInsertId: Int64) {
        _rowCount = rowCount
        _lastInserId = lastInsertId
    }


    public prop lastInsertId: Int64 {
        get() {
            return _lastInserId
        }
    }
    public prop rowCount: Int64 {
        get() {
            return _rowCount
        }
    }

}