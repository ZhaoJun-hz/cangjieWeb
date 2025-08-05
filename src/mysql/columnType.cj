package cangjieWeb.mysql

enum ColumnType {
    | Long
    | LongLong
    | VarString

    static func of (value: UInt8): ColumnType {
        match (value) {
            case 0x03 => Long
            case 0x08 => LongLong
            case 0xFD => VarString
            case _ => throw Exception("unsupport ColumnType value = ${value}")
        }
    }

    public func cjType(unsigned: Bool) {
        match (this) {
            case Long =>
                if (unsigned) {
                    "UInt32"
                } else {
                    "Int32"
                }
            case LongLong =>
                if (unsigned) {
                    "UInt64"
                } else {
                    "Int64"
                }

            case VarString => "String"
            
        }
    }
}