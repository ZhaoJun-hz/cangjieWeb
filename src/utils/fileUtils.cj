package cangjieWeb.utils
import std.os.currentDir
import std.fs.{File, Path}
public class FileUtils {
    public static let fileSeparator: String = if(currentDir().info.path.toString().contains("\\")) {
        "\\\\"
    }else {
        "/"
    }

    public func fileExist(path: String) {
        let filePath = Path(path)
        if (File.exists(filePath)) {
            return true
        } 
        return false
    }
}