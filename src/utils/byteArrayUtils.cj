package cangjieWeb.utils
import std.collection.{ArrayList}
import crypto.digest.{SHA256}
public class ByteArrayUtils {
    // 判断两个Array<Byte>数组是否相等，相等，返回true，否则，返回false
    public static func judgeByteArrayEqual(source: Array<Byte>, dest: Array<Byte>): Bool {
        if (source.size != dest.size) {
            return false
        }
        var result = true
        for (i in 0..source.size) {
            if(source[i] != dest[i]) {
                result = false
                break
            }
        }

        return result
    }
    
    public static func splitByteArray(source: Array<Byte>, separator: Array<Byte>, dropLast!: Bool = false) {
        let result = ArrayList<Array<Byte>>()
        let sourceSize = source.size
        let separatorSize = separator.size
        // 记录上一次匹配的索引下表 + separator 的长度
        var prevIndex = 0
        for(i in 0..sourceSize - separatorSize + 1) {
            if (ByteArrayUtils.judgeByteArrayEqual(source[i..i+separatorSize], separator)) {
                // 匹配上了
                // 开头就匹配上了，其实我们不需要
                if (i != 0) {
                    // 两个分隔符其实连着的，中间内容为空，也是不需要的
                    if (i != prevIndex) {
                        if(prevIndex == 0) {
                            result.append(source[0..i])
                        } else {
                            result.append(source[prevIndex ..i])
                        }
                    }
                }
                // 记录一下上一个匹配的位置，加上separator 的长度
                prevIndex = i + separatorSize
            }
        }
        if(!dropLast) {
            // 上一个匹配的索引小标 + 分隔符长度 不等于 原Byte数组的长度，说明有内容
            if (prevIndex + separatorSize != sourceSize) {
                result.append(source[prevIndex..])
            }
        }
        return result
    }

    // 在字节数组source 中查找目标target的第一个索引，找不到返回-1
    public static func indexByte(source: Array<Byte>, target: Byte): Int64 {
        for (i in 0 .. source.size) {
            if (source[i] == target) {
                return i
            }
        }
        return -1
    }

    // 小端序 字节数组  转 uint16
    public static func littleEndianUint16(b: Array<Byte>): UInt16 {
        return UInt16(b[0]) | UInt16(b[1]) << 8
    }

    private static var CACHING_SHA2_DIGEST_LENGTH = 32
    public static func scrambleCachingSha2(cipher: Array<Byte>, passwd: Array<Byte>):Array<Byte> {
        // 使用本包需要外部依赖 OpenSSL 3 的 crypto 动态库文件，故使用前需安装相关工具。
        // 并配置环境变量
        var sha2Instance = SHA256()
        var dig1 = Array<Byte>(CACHING_SHA2_DIGEST_LENGTH, item: 0)
        var dig2 = Array<Byte>(CACHING_SHA2_DIGEST_LENGTH, item: 0)
        var scramble1 = Array<Byte>(CACHING_SHA2_DIGEST_LENGTH, item: 0)
        
        sha2Instance.write(passwd)
        dig1 = sha2Instance.finish()
        sha2Instance.reset()
        sha2Instance.write(dig1)
        dig2 = sha2Instance.finish()
        sha2Instance.reset()
        sha2Instance.write(dig2)
        sha2Instance.write(cipher)
        scramble1 = sha2Instance.finish()
        sha2Instance.reset()
        var mysqlScrambleBuff = Array<Byte>(CACHING_SHA2_DIGEST_LENGTH, item: 0)
        xorString(dig1, mysqlScrambleBuff, scramble1, CACHING_SHA2_DIGEST_LENGTH)
        return mysqlScrambleBuff
    }
    
    public static func xorString(src: Array<Byte>, to: Array<Byte>,scramble:Array<Byte>,len:Int64) {
        var pos = 0
        var scrambleLen = scramble.size
        while (pos < len) {
            to[pos] = src[pos] ^ scramble[pos % scrambleLen]
            pos++
        }
    } 


    public static func appendLengthEncodedInteger(n: UInt64): Array<Byte> {
        let result = ArrayList<Byte>()
        if (n <= 250) {
            result.append(UInt8(n))
        } else if (n <= 0xffff) {
            result.append(0xfc)
            result.append(UInt8(n & 0xff))
            result.append(UInt8(n >> 8 & 0xff))
        } else if (n <= 0xffffff) {
            result.append(0xfd)
            result.append(UInt8(n & 0xff))
            result.append(UInt8(n >> 8 & 0xff))
            result.append(UInt8(n >> 16 & 0xff))
        } else {
            result.append(0xfe)
            result.append(UInt8(n & 0xff))
            result.append(UInt8(n >> 8 & 0xff))
            result.append(UInt8(n >> 16 & 0xff))
            result.append(UInt8(n >> 24 & 0xff))
            result.append(UInt8(n >> 32 & 0xff))
            result.append(UInt8(n >> 40 & 0xff))
            result.append(UInt8(n >> 48 & 0xff))
            result.append(UInt8(n >> 56 & 0xff))
        }
        return result.toArray()
    }

}