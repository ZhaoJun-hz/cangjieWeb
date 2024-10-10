package cangjieWeb.mysql

protected class MySqlField {
    private var tableName: String = ""
    private var name: String = ""
    private var length: UInt32 = 0
    private var flags: UInt16 = 0
    private var fieldType: UInt16 = 0
    private var decimals: Byte = 0
    private var charSet: UInt16 = 0

    public func getTableName() {
        return this.tableName
    }

    public func setTableName(tableName: String) {
        this.tableName = tableName
    }

    public func getName() {
        return this.name
    }

    public func setName(name: String) {
        this.name = name
    }

    public func getLength() {
        return this.length
    }

    public func setLength(length: UInt32) {
        this.length = length
    }

    public func getFlags() {
        return this.flags
    }

    public func setFlags(flags: UInt16) {
        this.flags = flags
    }

    public func getFieldType() {
        return this.fieldType
    }

    public func setFieldType(fieldType: UInt16) {
        this.fieldType = fieldType
    }

    public func getDecimals() {
        return this.decimals
    }

    public func setDecimals(decimals: Byte) {
        this.decimals = decimals
    }

    public func getCharSet() {
        return this.charSet
    }

    public func setCharSet(charSet: UInt16) {
        this.charSet = charSet
    }
}