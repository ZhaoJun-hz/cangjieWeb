package cangjieWeb.model
import cangjieWeb.macros.Json
import stdx.serialization.serialization.*
import stdx.encoding.json.*
@Json
public class Student {
    public var name: String = "闲不下来的程序猿"
    public var age: Int8 = 18

    func exam() {
        println("student is examing......")
    }

    func study() {
        println("student is studying......")
    }
}