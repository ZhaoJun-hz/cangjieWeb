package cangjieWeb.mysql
import std.net.{TcpSocket}

public class Buffer {
    // 当前读取到的下标
    private var idx: Int64 = 0
    // 当前有效的数据长度
    private var length: Int64 = 0
    // Byte数组，读取到的数据放到这里，必要的时候，会对数组进行扩容，以及整理数组
    private var buf: Array<Byte>
    // 对应的tcp连接
    private let socket: TcpSocket

    init(socket: TcpSocket) {
        this.socket = socket
        this.buf = Array<Byte>(4096, repeat: 0)
    }

    // readNext、fill、grow
    // readNext 读取指定数量的字节，如果数据不足，调用fill方法，从tcp读取更多的字节，并更新相关成员变量
    public func readNext(need: Int64): Array<Byte> {
        if(length < need) {
            fill(need)
        }

        let data = buf[idx .. idx + need]
        idx += need
        length -= need
        return data
    }
    // 检查是否有足够的数据，没有的话，从socket 读取数据
    public func fill(need: Int64) {
        if (length > 0 && idx > 0) {
            buf.copyTo(buf, idx, 0, length - idx)
        }
        if (need > buf.size) {
            grow(need)
        }
        idx = 0
        while(length < need) {
            var readSize = socket.read(buf[length..])
            length += readSize
        }

    }
    // 扩容，创建一个更大byte 数组
    public func grow(need: Int64) {
        let newBuf = Array<Byte>(need, repeat: 0)
        buf.copyTo(newBuf, 0, 0, length)
        this.buf = newBuf
    }

}