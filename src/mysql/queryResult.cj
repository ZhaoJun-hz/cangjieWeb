package cangjieWeb.mysql
import std.database.sql.*
import std.collection.{ArrayList}
import cangjieWeb.utils.ByteArrayUtils
public class MysqlQueryResult <: QueryResult {

    private let columns: ArrayList<MySqlField>
    private let rows: ArrayList<Array<Byte>>

    // 当前遍历到第几行，第几条数据
    private var tempRowsIndex = 0
    // 遍历当前行的第几个字段
    private var tempRowPos = 0

    // NULL_bitmap 开始的下标，固定为1，因为前面有占一个字节的packet_header
    private var nullBitMapStartPos = 1
    // null_bitmap 结束的下标 + 1 ,也就是真实数据开始的地方
    private var nullBitMapEndPos = 0

    init(columns: ArrayList<MySqlField>, rows: ArrayList<Array<Byte>>) {
        this.columns = columns
        this.rows = rows
        nullBitMapEndPos= (this.columns.size + 7 + 2) / 8 + 1
    }

    public prop columnInfos: Array<ColumnInfo> {
        get() {
            return ArrayList<ColumnInfo>().toArray()
        }
    }
    
    public func next(values: Array<SqlDbType>): Bool {
        tempRowPos = nullBitMapEndPos
        if( tempRowsIndex < rows.size) {
            for(i in 0 .. values.size) {
                fillData(values[i], i)
            }
            tempRowsIndex ++
            // 还有数据
            return true
        }
        // 没有数据
        return false
    }
    public func close(): Unit {

    }
    public func isClosed(): Bool {
        return false
    }

    private func fillData(value: SqlDbType, index: Int64) {
        match(value) {
            case v: SqlInteger => 
                let number = ByteArrayUtils.littleEndianUint32(rows[tempRowsIndex][tempRowPos..])
                v.value = Int32(number)
                tempRowPos += 4

            case v: SqlVarchar =>
                let (s, isNull, n) = ByteArrayUtils.readLengthEncodedString(rows[tempRowsIndex][tempRowPos..])
                v.value = String.fromUtf8(s)
                tempRowPos += n

            case v: SqlNullableInteger =>
                if (judgeOne(index)) {
                    v.value = Option.None
                } else {
                    let number = ByteArrayUtils.littleEndianUint32(rows[tempRowsIndex][tempRowPos..])
                    v.value = Int32(number)
                    tempRowPos += 4
                }
            case _ =>
                println("unsupport type")
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