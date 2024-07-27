package cangjieWeb.server

public class FileFormInfo {
    FileFormInfo(private let filename: String, private let content:Array<Byte>) {
    }

    public func getFilename() {
        return this.filename
    }

    public func getContent() {
        return this.content
    }
}