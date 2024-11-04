package cangjieWeb.utils
import std.process.*
import std.fs.{File, Path, exists}
public class FileUtils {
    public static let fileSeparator: String = if(Process.current.workingDirectory.toString().contains("\\")) {
        "\\\\"
    }else {
        "/"
    }

    public func fileExist(path: String) {
        let filePath = Path(path)
        if (exists(filePath)) {
            return true
        } 
        return false
    }
}