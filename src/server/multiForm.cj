package cangjieWeb.server
import encoding.url.Form
import std.collection.HashMap
class MultiForm {
    private var formCache: Form
    private let files: HashMap<String, Array<Byte>>

    MultiForm() {
        this.formCache = Form()
        this.files = HashMap<String, Array<Byte>>()
    }

    public func setForm(form: Form) {
        this.formCache = form
    }

    public func getForm() {
        return this.formCache
    }

    public func addFile(filename: String, content: Array<Byte>) {
        this.files.put(filename, content)
    }

    public func getFile(filename: String) {
        return this.files.get(filename)
    }
}