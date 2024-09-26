package cangjieWeb.mysql
import std.database.sql.{Connection, ConnectionState, Transaction, Statement}
import std.collection.{Map,HashMap}
import std.net.{TcpSocket, IPSocketAddress}
import cangjieWeb.utils.{ByteArrayUtils}
public class MysqlConnection <: Connection {

    private let config: Config

    private let socket: TcpSocket
    private let buffer: Buffer

    private var sequence: Byte = 0
    // 密码加密需要用的
    private var cipher: Array<Byte> = Array<Byte>()
    // 字符集
    private var charset:Byte = 0
    // 能力
    private var flags: UInt32 = 0
    // 认证插件名称
    private var plugin: String = ""


    public init(config: Config)  {
        this.config = config
        var socket = TcpSocket(IPSocketAddress.parse(config.address))
        // 三次握手
        socket.connect()
        this.socket = socket
        this.buffer = Buffer(socket)

        // 读HandShake包
        readInitPacket()
        // 发送HandShakeResponse
        writeAuthPacket()
    }

    public prop state: ConnectionState {
        get() {
            return ConnectionState.Connected
        }
    }
    public func createTransaction(): Transaction {
        return MySqlTransaction()
    }
    public func getMetaData(): Map<String, String> {
        HashMap([])
    }
    public func prepareStatement(sql: String): Statement {
        return MySqlStatement()
    }
    public func close(): Unit {

    }
    public func isClosed(): Bool {
        return false
    }

    private func readInitPacket() {
        let data = readPacket()

        // 协议版本: 1 字节
        // 服务器版本: 以 \0 结尾的字符串
        // 连接 ID: 4 字节
        // 密码加密部分1: 8 字节
        // 填充字节: 1 字节（始终为 0x00）
        // 能力标志（低 2 字节）: 2 字节
        // 字符集: 1 字节
        // 状态标志: 2 字节
        // 能力标志（高 2 字节）: 2 字节
        // 认证插件数据长度: 1 字节
        // 保留字节: 10 字节（全部为 0x00）
        // 密码加密部分: 可变长度（通常为 12 字节）
        // 认证插件：以 \0 结尾的字符串

        var pos = 1 + ByteArrayUtils.indexByte(data[1..], 0) + 1 + 4
        // 密码加密部分1: 8 字节
        cipher = cipher.concat(data[pos .. pos + 8])
        pos = pos + 8 + 1
        // 能力标志
        flags = UInt32(ByteArrayUtils.littleEndianUint16(data[pos .. pos + 2]))
        pos += 2
        // 字符集
        charset = data.get(pos).getOrThrow()
        pos = pos + 1
        // 状态标志 能力标志  认证插件数据长度 保留字节
        pos = pos + 2 + 2 + 1 + 10
        cipher = cipher.concat(data[pos .. pos + 12])
        pos += 13

        let end = ByteArrayUtils.indexByte(data[pos..], 0)
        if (end != -1) {
            plugin = String.fromUtf8(data[pos .. pos + end])
        }else {
            plugin = String.fromUtf8(data[pos ..])
        }
    }

    private func writeAuthPacket() {
        // 4 clientFlags
        // 4 max packet size
        // 1 charset
        // 23 保留位
        // username 以0结尾
        // 1 以0结尾
        // 1 密码长度
        // 密码
        // dbname
        // 21 认证插件

        var clientFlags: UInt32 = 
            clientProtocol41 |  
            clientSecureConn | 
            clientLongPassword | 
            clientTransactions | 
            clientLocalFiles |  
            clientPluginAuth |  
            clientMultiResults | 
            flags &
            clientLongFlag 

        let authResp = ByteArrayUtils.scrambleCachingSha2(cipher, config.password.toArray())

        let authRespLen = authResp.size
        let authRespLEI = ByteArrayUtils.appendLengthEncodedInteger(UInt64(authRespLen))
        if (authRespLEI.size > 1) {
            clientFlags |= clientPluginAuthLenEncClientData
        }

        var pktLen = 4 + 4 + 1 + 23 + config.username.toArray().size + 1 + authRespLEI.size + authResp.size + 21
        if (config.dbname.size > 0) {
            clientFlags |= UInt32(clientConnectWithDB)
            pktLen += config.dbname.toArray().size + 1
        }
        // 包头
        let data = Array<Byte>(pktLen + 4, item: 0)

        data[4] = UInt8(clientFlags & 0xff)
        data[5] = UInt8(clientFlags >> 8 & 0xff)
        data[6] = UInt8(clientFlags >> 16 & 0xff)
        data[7] = UInt8(clientFlags >> 24 & 0xff)
        // 8 9 10 11 max packet size
        data[12] = charset

        var pos = 13 + 23
        // username
        if(config.username.size > 0) {
            config.username.toArray().copyTo(data, 0, pos, config.username.toArray().size)
            pos += config.username.toArray().size
        }
        pos += 1
        
        //  密码长度
        authRespLEI.copyTo(data, 0, pos, authRespLEI.size)
        pos += authRespLEI.size

        // 密码
        authResp.copyTo(data, 0, pos, authResp.size)
        pos += authResp.size

        // dbname
        if (config.dbname.size > 0) {
            config.dbname.toArray().copyTo(data, 0, pos, config.dbname.toArray().size)
            pos += config.dbname.toArray().size
        }
        pos += 1
        plugin.toArray().copyTo(data, 0, pos, plugin.toArray().size)
        writePacket(data)
    }

    protected func readPacket(): Array<Byte> {
        let data = buffer.readNext(4)
        let pktLen = Int64(UInt32(data[0]) | UInt32(data[1]) << 8 |  UInt32(data[2]) << 16)

        if (data[4] != sequence) {
            println("ERROR sequence NOT EQUAL")
        }
        sequence ++

        let resultData = buffer.readNext(pktLen)

        return resultData
    }
    // data 包含包头
    protected func writePacket(data: Array<Byte>) {
        let pktlen = data.size - 4

        data[0] = UInt8(pktlen & 0xff)
        data[1] = UInt8(pktlen >> 8)
        data[2] = UInt8(pktlen >> 16)
        data[3] = sequence

        this.socket.write(data)
        sequence ++
    }
}