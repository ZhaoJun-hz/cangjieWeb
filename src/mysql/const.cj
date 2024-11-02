package cangjieWeb.mysql

public let maxPacketSize = 1<<24 - 1


public let clientLongPassword: UInt32  = 1
public let clientLongFlag: UInt32  = 4
public let clientConnectWithDB: UInt32  = 8
public let clientLocalFiles: UInt32 = 128
public let clientProtocol41: UInt32 = 512
public let clientTransactions: UInt32 = 8192
public let clientSecureConn: UInt32 = 32768
public let clientMultiResults:UInt32 = 131072
public let clientPluginAuth:UInt32 = 524288
public let clientConnectAttrs:UInt32 = 1048576
public let clientPluginAuthLenEncClientData:UInt32 = 2097152

public let cachingSha2PasswordRequestPublicKey: Byte = UInt8(2)

// COM_STMT_PREPARE_OK包第一部分status
public let iOK: Byte = UInt8(0)


// COM_STMT_PREPARE command
public let comStmtPrepare: Byte = 22
// COM_STMT_EXECUTE command   0x16
public let comStmtExecute: Byte = 23

// mysql field type
public let fieldTypeLong: Byte = 3
public let fieldTypeNULL: Byte = 6
public let fieldTypeLongLong: Byte = 8
public let fieldTypeVarString: Byte = 253