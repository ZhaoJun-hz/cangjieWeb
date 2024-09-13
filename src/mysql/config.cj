package cangjieWeb.mysql
import std.collection.HashMap
public class Config {
    public var username = ""
    public var password = ""
    public var address = ""
    public var protocol = "" // tcp
    public var dbname = ""
    public var params = HashMap<String, String>()
}