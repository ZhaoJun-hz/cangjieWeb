package cangjieWeb.utils

public class FlagUtils {
    public static func hasFlag(flag: UInt16, targetFlag: UInt16): Bool {
        return (flag & targetFlag) != 0
    }
}