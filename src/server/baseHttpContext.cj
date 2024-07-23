package cangjieWeb.server
import serialization.serialization.{Serializable}
import encoding.json.ToJson
import encoding.url.{Form}
import net.http.{HttpContext}
public class BaseHttpContext {
    private let context: HttpContext 
    private var formInitFlag: Bool
    private var queryInitFlag: Bool
    private var queryCache: Form
    private var formCache: MultiForm

    BaseHttpContext(context: HttpContext ) {
        this.context = context
        this.queryCache = Form()
        this.formCache = MultiForm()
        this.formInitFlag = false
        this.queryInitFlag = false
    }

    public func GetForm(key: String) {
        formInit()
        return this.formCache.getForm().get(key).getOrDefault({ => ""})
    }

    public func GetFormDefault(key: String, defaultValue: String) {
        formInit()
        return this.formCache.getForm().get(key).getOrDefault({ => defaultValue})
    }

    public func GetFormAll(key: String) {
        formInit()
        return this.formCache.getForm().getAll(key)
    }

    public func GetQuery(key: String) {
        queryInit()
        return this.queryCache.get(key).getOrDefault({ => ""})
    }

    public func GetQueryDefault(key: String, defaultValue: String) {
        queryInit()
        return this.queryCache.get(key).getOrDefault({ => defaultValue})
    }

    public func GetQueryAll(key: String) {
        queryInit()
        return this.queryCache.getAll(key)
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

    private func queryInit() {
        if(queryInitFlag) {
            return
        }
        this.queryCache = context.request.url.queryForm
        queryInitFlag = true
    }

    private func formInit() {
        if (formInitFlag) {
            return 
        }
        let contentType = this.context.request.headers.getFirst("Content-Type") ?? ""
        if (contentType.startsWith("application/x-www-form-urlencoded")) {
            this.formCache.setForm(this.context.request.form)
        }else if (contentType.startsWith("multipart/form-data")) {
            let contentLength = this.context.request.headers.getFirst("Content-Length") ?? "0"
            let formDataParse = FormDataParse(contentType, contentLength, this.context.request.body)
            this.formCache = formDataParse.parse()
        }
        formInitFlag = true
    }
}