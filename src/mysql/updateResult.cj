package cangjieWeb.mysql
import std.database.sql.{UpdateResult}
public class MySqlUpdateResult <: UpdateResult {
    public prop lastInsertId: Int64 {
        get() {
            return 0
        }
    }
    public prop rowCount: Int64 {
        get() {
            return 0
        }
    }

}