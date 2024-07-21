package cangjieWeb.server
import cangjieWeb.utils.ByteArrayUtils
import std.io.{InputStream,BufferedInputStream}
import std.collection.{ArrayList}
import std.convert.{Parsable}
import encoding.url.{Form}
import std.fs.{Path, File, OpenOption}
import std.os.{currentDir}
class FormDataParse {
    private let bodyStream: InputStream
    private let contentType: String
    private let contentLength: String

    FormDataParse(contentType: String, contentLength: String, bodyStream: InputStream) {
        this.contentType = contentType
        this.contentLength = contentLength
        this.bodyStream = bodyStream
    }

    func parse(): Form {
        let result = Form()
        let bodyParts = generateBodyParts()
        for(bodyPart in bodyParts) {
            if(bodyPart.judgeFile()) {
                // 文件
                let filePath: Path = Path("${currentDir().info.path.toString()}\\upload\\${bodyPart.getFilename()}")
                // let filePath: Path = Path("${currentDir().info.path.toString()}\\upload\\${bodyPart.getFilename()}")
                if(File.exists(filePath)) {
                    File.delete(filePath)
                }
                var file = File(filePath, OpenOption.Create(false))
                file.write(bodyPart.getBodyPart())
                file.close()
            } else {
                result.add(bodyPart.getName(), bodyPart.getBodyContent())
            }
            
        }
        return result
    }

    private func generateBodyParts() {
        let result = ArrayList<BodyPart>()
        let boundary = getBoundary()
        let bodySeparator = getBodySeparator(boundary)
        let length = Int64.parse(this.contentLength) 

        let bodyResult = Array<Byte>(length, item:0)
        let bufferedInputStream = BufferedInputStream(this.bodyStream)
        // 获取真实请求的字节数组
        bufferedInputStream.read(bodyResult)

        let splitByteArray = ByteArrayUtils.splitByteArray(bodyResult, bodySeparator, dropLast: false)
        for(i in 0.. splitByteArray.size) {
            if (i != splitByteArray.size - 1) {
                let contentByteArray = ByteArrayUtils.splitByteArray(splitByteArray[i], "\r\n\r\n".toArray(), dropLast: false)
                // TODO 这里可以将 contentByteArray 打印一下，以及对应的值
                result.append(BodyPart(contentByteArray[0], contentByteArray[1]))
            } else {
                // 最后一个元素
                let stopIndex = splitByteArray[i].size - bodySeparator.size - 2
                let contentByteArray = ByteArrayUtils.splitByteArray(splitByteArray[i][0..stopIndex], "\r\n\r\n".toArray(), dropLast: false)
                // TODO 这里可以将 contentByteArray 打印一下，以及对应的值
                result.append(BodyPart(contentByteArray[0], contentByteArray[1]))
            }
            
        }
        return result
    }

    private func getBoundary() {
        this.contentType["multipart/form-data; boundary=".size..]
    }
    private func getBodySeparator(boundary: String) {
        "--${boundary}\r\n".toArray()
    }
}

class BodyPart {
    // 头
    // Content-Disposition: form-data; name="id"
    private let headerPart: Array<Byte>
    // 内容
    // 100
    private let bodyPart: Array<Byte>
    private var name = ""

    private var fileFlag = false
    private var filename = ""

    BodyPart(headerPart: Array<Byte>, bodyPart: Array<Byte>) {
        this.headerPart = headerPart
        this.bodyPart = bodyPart[0..bodyPart.size - 2]
        let headerByteArray = ByteArrayUtils.splitByteArray(headerPart, "\r\n".toArray(), dropLast: false)
        // TODO 这里可以将headerByteArray 打印出来，打印内容和数组
        // headerByteArray[0]  Content-Disposition: form-data; name="id"
        let header = String.fromUtf8(headerByteArray[0])
        let headers = header.split(";", removeEmpty:true)
        if (header.contains("filename")) {
            // 文件
            fileFlag = true
            for(tempHeader in headers) {
                let tmpHeader = tempHeader.trimAscii()
                if (tmpHeader.startsWith("filename")) {
                    // filename="xxx"
                    this.filename = tmpHeader[10..tmpHeader.size - 1]
                }
            }
        }else {
            // 普通字段
            for(tempHeader in headers) {
                // tmpHeader  name="id"
                let tmpHeader = tempHeader.trimAscii()
                if (tmpHeader.startsWith("name")) {
                    this.name = tmpHeader[6..tmpHeader.size - 1]
                }
            }
        }
        
    }

    func getName() {
        return this.name
    }

    func getBodyContent() {
        return String.fromUtf8(this.bodyPart)
    }

    func judgeFile() {
        return this.fileFlag
    }

    func getFilename() {
        return this.filename
    }

    func getBodyPart() {
        return this.bodyPart
    }
}