package model
from serialization import serialization.*
from encoding import json.*

public class User <: Serializable<User> {

    public var name: String = ""
    public var age: Int64 = 0
    public var phone: String = ""
    public var email: String = ""

    public func serialize(): DataModel {
        return DataModelStruct().add(field<String>("name", name))
            .add(field<Int64>("age", age))
            .add(field<String>("phone", phone))
            .add(field<String>("email", email))
    }

    public static func deserialize(dm: DataModel): User {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }

        var result = User()
        result.age = Int64.deserialize(dms.get("age"))
        result.name = String.deserialize(dms.get("name"))
        result.phone = String.deserialize(dms.get("phone"))
        result.email = String.deserialize(dms.get("email"))
        return result
    }

}