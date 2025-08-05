package cangjieWeb.mysql
import std.database.sql.*
import std.collection.{ArrayList}
import cangjieWeb.utils.ByteArrayUtils
public class MysqlQueryResult <: QueryResult {

    private let columns: ArrayList<ColumnInfo>
    private let rows: ArrayList<Array<Byte>>

    // 当前遍历到第几行，第几条数据
    private var tempRowsIndex = -1
    // 遍历当前行的第几个字段
    private var tempRowPos = 0

    // NULL_bitmap 开始的下标，固定为1，因为前面有占一个字节的packet_header
    private var nullBitMapStartPos = 1
    // null_bitmap 结束的下标 + 1 ,也就是真实数据开始的地方
    private var nullBitMapEndPos = 0

    init(columns: ArrayList<ColumnInfo>, rows: ArrayList<Array<Byte>>) {
        this.columns = columns
        this.rows = rows
        nullBitMapEndPos= (this.columns.size + 7 + 2) / 8 + 1
    }

    public prop columnInfos: Array<ColumnInfo> {
        get() {
            return columns.toArray()
        }
    }

    public func get<T>(index: Int): T {
        getOrNull<T>(index).getOrThrow()
    }

    public func getOrNull<T>(index: Int): ?T {
        if (index <= 0 || index > columns.size) {
            throw SqlException("index : ${index} out of bounds : ${columns.size}")
        }
        let pos = index - 1
        getData<T>(pos)

    }

    public func next(): Bool {
        tempRowPos = nullBitMapEndPos
        if (tempRowsIndex < rows.size - 1) {
            tempRowsIndex ++
            return true
        }
        return false
    }

    @Deprecated
    public func next(values: Array<SqlDbType>): Bool {
        throw Exception("Deprecated method")
    }
    public func close(): Unit {

    }
    public func isClosed(): Bool {
        return false
    }

    private func getData<T>(index: Int64): Option<T> {
        let value = columns
        let columnInfo = columns[index]
        match(columnInfo.typeName) {
            case "Int32" => 
                if (!judgeOne(index)) {
                    let number = ByteArrayUtils.littleEndianUint32(rows[tempRowsIndex][tempRowPos..])
                    tempRowPos += 4
                    return Int32(number) as T
                } else {
                    return  Option<T>.None
                }
            case "String" => 
                let (s, isNull, n) = ByteArrayUtils.readLengthEncodedString(rows[tempRowsIndex][tempRowPos..])
                let temp = String.fromUtf8(s)
                tempRowPos += n
                return temp as T


            case _ => throw Exception("unsupport type")
        }
    }

    private func judgeOne(index: Int64): Bool {
        let bytePos = (index + 2) / 8
        let bitPos = (index + 2) % 8

        // 获取当前位置bytePos的值
        let number = rows[tempRowsIndex][nullBitMapStartPos + bytePos]

        return (number & (1 << bitPos)) != 0
    }
}