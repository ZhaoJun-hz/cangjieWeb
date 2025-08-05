package cangjieWeb.mysql
import std.database.sql.{ColumnInfo}
import cangjieWeb.utils.FlagUtils

protected class MySqlField <: ColumnInfo {
    private let _displaySize: Int64
    private let _length: Int64
    private let _name: String
    private let _nullable: Bool
    private let _scale: Int64
    private let _typeName: String

    protected init(name: String, columnType: UInt8, columnLength: UInt32, decimals: UInt8, flags: UInt16) {
        let unsigned = FlagUtils.hasFlag(flags, 1 << 5)
        this._name = name
        this._length = Int64(columnLength)
        this._displaySize = Int64(columnLength)
        this._scale = Int64(decimals)
        this._typeName = ColumnType.of(columnType).cjType(unsigned)
        this._nullable = FlagUtils.hasFlag(flags, 1)
    }

    public override prop name: String {
        get() {
            return _name
        }
    }

    public override prop typeName: String {
        get() {
            return _typeName
        }
    }

    public override prop displaySize: Int64 {
        get() {
            return _displaySize
        }
    }

    public override prop length: Int64 {
        get() {
            return _length
        }
    }

    public override prop scale: Int64 {
        get() {
            return _scale
        }
    }

    public override prop nullable: Bool {
        get() {
            return _nullable
        }
    }
}