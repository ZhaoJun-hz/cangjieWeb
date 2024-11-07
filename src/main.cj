// package cangjieWeb
// import net.http.{ServerBuilder, FuncHandler, HttpRequestHandler, HttpStatusCode}
// import cangjieWeb.server.{Router, Engine, HandlerFunc, BaseHttpContext}
// import cangjieWeb.model.User
// import cangjieWeb.utils.FileUtils
// import std.os.currentDir

// func GroupMiddlewareFun1(next: HandlerFunc): HandlerFunc {
//     return { ctx=>
//         println("pre GroupMiddlewareFun1")
//         next(ctx)
//         println("post GroupMiddlewareFun1")
//     }
// }

// func GroupMiddlewareFun2(next: HandlerFunc): HandlerFunc {
//     return { ctx=>
//         println("pre GroupMiddlewareFun2")
//         next(ctx)
//         println("post GroupMiddlewareFun2")
//     }
// }


// func RouterMiddlewareFun1(next: HandlerFunc): HandlerFunc {
//     return { ctx=>
//         println("pre RouterMiddlewareFun1")
//         next(ctx)
//         println("post RouterMiddlewareFun1")
//     }
// }

// func RouterMiddlewareFun2(next: HandlerFunc): HandlerFunc {
//     return { ctx=>
//         println("pre RouterMiddlewareFun2")
//         next(ctx)
//         println("post RouterMiddlewareFun2")
//     }
// }

// func userList(context: BaseHttpContext): Unit{
//     println("user list")
//     context.HTML(HttpStatusCode.STATUS_OK,"<h1>user list</h1>")
// }

// func userGet(context: BaseHttpContext): Unit{
//     println("user get")
//     let user = User()
//     user.name = "闲不下来的程序猿"
//     user.age = 18
//     user.phone = "18266666666"
//     user.email = "zhao@163.com"
//     context.Json(HttpStatusCode.STATUS_OK, user)
// }

// func userInfo(context: BaseHttpContext): Unit{
//     println("user info")
//     let id = context.GetQuery("id")
//     let name = context.GetQueryDefault("name", "闲不下来的程序猿")
//     let phone = context.GetQueryDefault("phone", "18234567890")
//     let email = context.GetQueryAll("email")
//     println("id = ${id}, name=${name}, phone=${phone}, email = ${email}")
//     let user = User()
//     user.name = name
//     user.age = 18
//     user.phone = phone
//     user.email = "zhao@163.com"
//     context.Json(HttpStatusCode.STATUS_OK, user)
// }

// func userAdd(context: BaseHttpContext): Unit{
//     println("user add")
//     let phone = context.GetForm("phone")
//     let password = context.GetFormDefault("password","123456")
//     let email = context.GetFormAll("email")
//     let name = context.GetForm("name")
//     let `from` = context.GetQuery("from")
//     println("from = ${`from`}, name=${name}, password = ${password} phone=${phone}, email = ${email}")
//     context.String(HttpStatusCode.STATUS_OK, "user add")
// }

// func formData(context: BaseHttpContext): Unit {
//     let name = context.GetForm("name")
//     let id = context.GetFormDefault("id", "123456")
//     let number = context.GetFormDefault("number", "123444444")
//     let arrays = context.GetFormAll("arrays")
//     let `from` = context.GetQuery("from")
//     println("from = ${`from`}, name = ${name}, id = ${id} number = ${number}, arrays = ${arrays}")
//     let fileExist = context.formFileExist("file")
//     var filePath = "${FileUtils.fileSeparator}upload"
//     if (fileExist) {
//         let fileFormInfo = context.getFormFile("file")
//         filePath = filePath + "${FileUtils.fileSeparator}" + fileFormInfo.getFilename()
//         context.saveUploadFile("file", "${currentDir().info.path.toString()}${filePath}")
//     }
//     let downFileUrl = "/test/download?filePath=${filePath}"
//     context.String(HttpStatusCode.STATUS_OK, downFileUrl)
// }

// func download(context: BaseHttpContext):Unit {
//     let filePath = context.GetQuery("filePath")
//     let fileUtlis = FileUtils()
//     if (!fileUtlis.fileExist("${currentDir().info.path.toString()}${filePath}")) {
//         context.String(HttpStatusCode.STATUS_NOT_FOUND, "文件不存在")
//     }
//     context.FileDownload(HttpStatusCode.STATUS_OK, "${currentDir().info.path.toString()}${filePath}")
// }

// main() {
//     let engine = Engine(8888)
//     let user = engine.addRouterGroup("/user")
//     user.Use(GroupMiddlewareFun1, GroupMiddlewareFun2)
//     user.Get("/list", userList, RouterMiddlewareFun1, RouterMiddlewareFun2)
//     user.Put("/add", userAdd)
//     user.Get("/get", userGet)
//     user.Get("/info", userInfo)

//     let test = engine.addRouterGroup("test")
//     test.Post("formData", formData)
//     test.Get("download", download)
//     engine.run()
// }
package cangjieWeb
import cangjieWeb.model.School
import serialization.serialization.*
import encoding.json.*
import std.reflect.*
import cangjieWeb.annotation.Validate
import std.database.sql.*
import cangjieWeb.mysql.MySqlDatasource
import std.collection.ArrayList

main() {

    testNull()
}

func testNull() {
    let connectionString = "root:QWERtyui1234@tcp(10.166.66.14:3306)/admin-api"
    let opts = [
        ("cachePrepStmts", "true")
    ]
    let drv = DriverManager.getDriver("mysql") ?? return
    let ds = drv.open(connectionString, opts)
    let connection = ds.connect()

    let deleteTable = """
        drop table if exists `sys_dept_null`;
    """
    let deleteTableStatement = connection.prepareStatement(deleteTable)
    let deleteTableParams = ArrayList<SqlDbType>()
    let deleteTableResult = deleteTableStatement.update(deleteTableParams.toArray())
    println("delete table sys_dept_null if exists success")

    let createTable = """
        CREATE TABLE `sys_dept_null` (
            `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
            `parent_id` int COMMENT '父id',
            `dept_type` int COMMENT '部门类型（1->公司, 2->中心，3->部门）',
            `dept_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '部门名称',
            `dept_status` int COMMENT '部门状态（1->正常 2->停用）',
            `create_time` int COMMENT '创建时间',
            `update_time` int COMMENT '更新时间',
            `delete_time` int COMMENT '删除时间',
            PRIMARY KEY (`id`) USING BTREE,
            UNIQUE KEY `dept_name` (`dept_name`) USING BTREE
        ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin ROW_FORMAT=DYNAMIC COMMENT='部门表';"""

    let createTableStatement = connection.prepareStatement(createTable)
    let createTableParams= ArrayList<SqlDbType>()
    let createTableResult = createTableStatement.update(createTableParams.toArray())
    println("create table sys_dept success")

    let insertTable = """
        INSERT INTO `admin-api`.sys_dept_null(parent_id, dept_type, dept_name, dept_status, create_time, update_time, delete_time) VALUES(?, ?, ?, ?, ?, ?, ?);""" 
    let insertTableStatement = connection.prepareStatement(insertTable)

    var companyUpdateResult = insertTableStatement.update(SqlNullableInteger(None), SqlInteger(1), SqlVarchar("cangjie company"),
        SqlNullableInteger(None), SqlNullableInteger(None), SqlInteger(1), SqlInteger(2))

    var heNanUpdateResult = insertTableStatement.update(SqlInteger(Int32(companyUpdateResult.lastInsertId)), SqlInteger(2), SqlVarchar("henan center"), 
        SqlNullableInteger(None),SqlInteger(1),SqlNullableInteger(None), SqlInteger(2))
   
    var zheJiangUpdateResult = insertTableStatement.update(SqlInteger(Int32(companyUpdateResult.lastInsertId)), SqlInteger(2), SqlVarchar("zhejiang center"), 
        SqlNullableInteger(None), SqlInteger(1),SqlInteger(2),SqlNullableInteger(None))

    let id = SqlInteger(0)
    let parentId = SqlNullableInteger(None)
    let deptType = SqlNullableInteger(None)
    let deptName = SqlVarchar("")
    let deptStatus = SqlNullableInteger(None)
    let createTime = SqlNullableInteger(None)
    let updateTime = SqlNullableInteger(None)
    let deleteTime = SqlNullableInteger(None)

    let statement = connection.prepareStatement("select * from `sys_dept_null`;")
    let param = ArrayList<SqlDbType>()
    let queryResult = statement.query(param.toArray())
    var tempIndex = 1
    println("query sys_dept all data")
    while(queryResult.next(id, parentId, deptType, deptName, deptStatus, createTime, updateTime, deleteTime)) {
        println(" ${tempIndex} rows data, id = ${id.value}, parentId = ${parentId.value}, " + 
            "deptType = ${deptType.value}, deptName = ${deptName.value}, deptStatus = ${deptStatus.value}, " +
            "createTime = ${createTime.value}, updateTime = ${updateTime.value}, deleteTime = ${deleteTime.value}"
        )
        tempIndex ++ 
    }
}