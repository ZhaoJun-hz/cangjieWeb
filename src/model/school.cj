package cangjieWeb.model
import cangjieWeb.macros.Json
import stdx.serialization.serialization.*
import stdx.encoding.json.*
import cangjieWeb.annotation.Validate
@Json
public class School {
    @Validate["required"]
    public var name: String = "中华路小学"
}