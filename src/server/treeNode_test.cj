package cangjieWeb.server
import std.unittest.*

@Test
func testTreeNode() {

    let root = TreeNode("/", "")
    root.put("user/list")
    root.put("user/add")

    root.put("/product/:id/:name")

    root.put("/dept/*")

    root.put("/menu/*/info")

    var path = "/user/list" 
    var result = root.get(path)
    if (result.isNone()) {
        @Fail("path = ${path} found Error")
    }

    path = "/user/add" 
    result = root.get(path)
    if (result.isNone()) {
        @Fail("path = ${path} found Error")
    }

    path = "/user/ad" 
    result = root.get(path)
    if (result.isSome()) {
        @Fail("path = ${path} found Error")
    }

    path = "/product/100/asdf" 
    result = root.get(path)
    if (result.isNone()) {
        @Fail("path = ${path} found Error")
    }

    path = "/product/100" 
    result = root.get(path)
    if (result.isSome()) {
        @Fail("path = ${path} found Error")
    }

    path = "/dept/hello" 
    result = root.get(path)
    if (result.isNone()) {
        @Fail("path = ${path} found Error")
    }

    path = "/dept/hi" 
    result = root.get(path)
    if (result.isNone()) {
        @Fail("path = ${path} found Error")
    }

    path = "/menu/aaa/info" 
    result = root.get(path)
    if (result.isNone()) {
        @Fail("path = ${path} found Error")
    }
}