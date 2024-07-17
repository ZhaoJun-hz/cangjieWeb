package cangjieWeb.server
import serialization.serialization.{Serializable}
import encoding.json.ToJson
import encoding.url.{Form}
import net.http.{HttpContext}
public class BaseHttpContext {
    private let context: HttpContext 
    private let queryForm: Form
    private let formContent: Form

    BaseHttpContext(context: HttpContext ) {
        this.context = context
        this.queryForm = context.request.url.queryForm
        this.formContent = context.request.form
    }

    public func GetForm(key: String) {
        return this.formContent.get(key).getOrDefault({ => ""})
    }

    public func GetFormDefault(key: String, defaultValue: String) {
        return this.formContent.get(key).getOrDefault({ => defaultValue})
    }

    public func GetFormAll(key: String) {
        return this.formContent.getAll(key)
    }

    public func GetQuery(key: String) {
        return this.queryForm.get(key).getOrDefault({ => ""})
    }

    public func GetQueryDefault(key: String, defaultValue: String) {
        return this.queryForm.get(key).getOrDefault({ => defaultValue})
    }

    public func GetQueryAll(key: String) {
        return this.queryForm.getAll(key)
    }

    public func HTML(status: UInt16, content: String) {
        this.context.responseBuilder.header("content-type", "text/html; charset=utf-8").status(status).body(content)
    }

    public func String(status: UInt16, content: String) {
        this.context.responseBuilder.status(status).body(content)
    }

    public func Json<T>(status: UInt16, data: T) where T <: Serializable<T> {
         this.context.responseBuilder.header("content-type", "text/json; charset=utf-8").status(status)
         .body(data.serialize().toJson().asObject().toJsonString())
    }
}