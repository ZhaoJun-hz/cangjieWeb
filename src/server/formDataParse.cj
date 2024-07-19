package cangjieWeb.server
import cangjieWeb.utils.ByteArrayUtils
import std.io.{InputStream,BufferedInputStream}
import std.collection.{ArrayList}
import std.convert.{Parsable}
import encoding.url.{Form}
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
            result.add(bodyPart.getName(), bodyPart.getBodyContent())
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

        let splitByteArray = ByteArrayUtils.splitByteArray(bodyResult, bodySeparator, dropLast: true)
        for(byteContent in splitByteArray) {
            // println(String.fromUtf8(byteContent))
            let contentByteArray = ByteArrayUtils.splitByteArray(byteContent, "\r\n".toArray(), dropLast: true)
            result.append(BodyPart(contentByteArray[0], contentByteArray[1]))
        }
        return result
    }

    private func getBoundary() {
        this.contentType["multipart/form-data; boundary=".size..]
    }
    private func getBodySeparator(boundary: String) {
        "--${boundary}".toArray()
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

    BodyPart(headerPart: Array<Byte>, bodyPart: Array<Byte>) {
        this.headerPart = headerPart
        this.bodyPart = bodyPart
        let headerByteArray = ByteArrayUtils.splitByteArray(headerPart, "\r".toArray(), dropLast: false)
        // headerByteArray[0]  Content-Disposition: form-data; name="id"
        let header = String.fromUtf8(headerByteArray[0])
        let headers = header.split(";", removeEmpty:true)
        for(tempHeader in headers) {
            // tmpHeader  name="id"
            let tmpHeader = tempHeader.trimAscii()
            if (tmpHeader.startsWith("name")) {
                this.name = tmpHeader[6..tmpHeader.size - 1]
            }
        }
    }

    func getName() {
        return this.name
    }

    func getBodyContent() {
        return String.fromUtf8(this.bodyPart)
    }
}