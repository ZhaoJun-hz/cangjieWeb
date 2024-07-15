package cangjieWeb.server
import std.collection.{ArrayList}
class TreeNode {
    // /info/hello/abc
    let path: String                    // info             hello            abc 
    let fullPath: String                // /info            /info/hello     /info/hello/abc
    var isEnd: Bool
    let child: ArrayList<TreeNode>

    TreeNode(path: String, fullPath: String) {
        this.path = path
        this.fullPath = fullPath
        this.isEnd = true
        this.child = ArrayList<TreeNode>()
    }
    // /info/hello/abc
    public func put(path: String) {
        var root = this
        let paths = path.split("/", removeEmpty: true)
        for (tempPath in paths) {
            let child = root.child
            var isMatch = false
            for(tempTreeNode in child) {
                if(tempTreeNode.path == tempPath) {
                    root = tempTreeNode
                    isMatch = true
                    break
                }
            }
            // 没有匹配，需要创建一个TreeNode
            if (!isMatch) {
                let newTreeNode = TreeNode(tempPath, root.fullPath + "/" + tempPath)
                root.child.append(newTreeNode)
                root.isEnd = false
                root = newTreeNode
            }
        }

    }
    // /info/hello/abcd
    public func get(path: String): Option<TreeNode> {
        var root = this
        let paths = path.split("/", removeEmpty: true)
        for(i in 0..paths.size) {
            let tempPath = paths[i]
            let child = root.child
            for(tempTreeNode in child) {
                if(tempTreeNode.path == tempPath || tempTreeNode.path == "*" || tempTreeNode.path.contains(":")) {
                    // 当前节点匹配了
                    root = tempTreeNode
                    // 是否已经完成了整个路径的匹配，如果完成了，就需要返回了
                    if (i == paths.size - 1 && tempTreeNode.isEnd) {
                        return tempTreeNode
                    }
                    break
                }
            }
        }
        return None
    }
}