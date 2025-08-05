package cangjieWeb.server
import stdx.encoding.url.Form
import std.collection.HashMap
class MultiForm {
    private var formCache: Form
    private let files: HashMap<String, FileFormInfo>

    MultiForm() {
        this.formCache = Form()
        this.files = HashMap<String, FileFormInfo>()
    }

    public func setForm(form: Form) {
        this.formCache = form
    }

    public func getForm() {
        return this.formCache
    }

    public func addFile(file:String, filename: String, content: Array<Byte>) {
        this.files.add(file, FileFormInfo(filename, content))
    }

    public func getFile(file: String) {
        return this.files.get(file)
    }

    public func existFile(file: String) {
        return this.files.contains(file)
    }
}