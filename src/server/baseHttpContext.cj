package cangjieWeb.server
import serialization.serialization.{Serializable}
import encoding.json.ToJson
import encoding.url.{Form}
import net.http.{HttpContext, HttpStatusCode}
import std.fs.{Path, File, OpenOption, exists, remove}
import cangjieWeb.utils.FileUtils
import std.io.readToEnd
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

    public func formFileExist(name: String) {
        formInit()
        return this.formCache.existFile(name)
    }

    public func getFormFile(name: String) {
        formInit()
        return this.formCache.getFile(name).getOrDefault({=> FileFormInfo("", Array<Byte>())})
    }

    public func saveUploadFile(name: String, path: String) {
        let filePath = Path(path)
        if(exists(filePath)) {
            remove(filePath)
        }
        var saveFile = File(filePath, OpenOption.Create(false))
        let fileFormInfo = this.formCache.getFile(name).getOrDefault({=> FileFormInfo("", Array<Byte>())})
        saveFile.write(fileFormInfo.getContent())
        saveFile.close()
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

    public func FileDownload(status: UInt16, filePath: String) {
        let fileUtlis = FileUtils()
        if (!fileUtlis.fileExist(filePath)) {
            String(HttpStatusCode.STATUS_NOT_FOUND, "文件不存在")
        }

        var fileInfo: File = File(filePath, OpenOption.Open(true, false))
        this.context.responseBuilder
            // Content-Disposition: attachment; filename=file5983940017135638617.tmp.txt
            .header("Content-Disposition", "attachment; filename=${fileInfo.info.path.fileName}")
            // Content-Type: application/octet-stream;
            .header("Content-Type", "application/octet-stream;")
            // Content-Length: 16
            .header("Content-Length", "${fileInfo.length}")
            .body(readToEnd(fileInfo))
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