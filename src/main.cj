package cangjieWeb
import net.http.{ServerBuilder, FuncHandler, HttpRequestHandler, HttpStatusCode}
import cangjieWeb.server.{Router, Engine, HandlerFunc, BaseHttpContext}
import cangjieWeb.model.User

func GroupMiddlewareFun1(next: HandlerFunc): HandlerFunc {
    return { ctx=>
        println("pre GroupMiddlewareFun1")
        next(ctx)
        println("post GroupMiddlewareFun1")
    }
}

func GroupMiddlewareFun2(next: HandlerFunc): HandlerFunc {
    return { ctx=>
        println("pre GroupMiddlewareFun2")
        next(ctx)
        println("post GroupMiddlewareFun2")
    }
}


func RouterMiddlewareFun1(next: HandlerFunc): HandlerFunc {
    return { ctx=>
        println("pre RouterMiddlewareFun1")
        next(ctx)
        println("post RouterMiddlewareFun1")
    }
}

func RouterMiddlewareFun2(next: HandlerFunc): HandlerFunc {
    return { ctx=>
        println("pre RouterMiddlewareFun2")
        next(ctx)
        println("post RouterMiddlewareFun2")
    }
}

func userList(context: BaseHttpContext): Unit{
    println("user list")
    context.HTML(HttpStatusCode.STATUS_OK,"<h1>user list</h1>")
}

func userGet(context: BaseHttpContext): Unit{
    println("user get")
    let user = User()
    user.name = "闲不下来的程序猿"
    user.age = 18
    user.phone = "18266666666"
    user.email = "zhao@163.com"
    context.Json(HttpStatusCode.STATUS_OK, user)
}

func userInfo(context: BaseHttpContext): Unit{
    println("user info")
    let id = context.GetQuery("id")
    let name = context.GetQueryDefault("name", "闲不下来的程序猿")
    let phone = context.GetQueryDefault("phone", "18234567890")
    let email = context.GetQueryAll("email")
    println("id = ${id}, name=${name}, phone=${phone}, email = ${email}")
    let user = User()
    user.name = name
    user.age = 18
    user.phone = phone
    user.email = "zhao@163.com"
    context.Json(HttpStatusCode.STATUS_OK, user)
}

func userAdd(context: BaseHttpContext): Unit{
    println("user add")
    let phone = context.GetForm("phone")
    let password = context.GetFormDefault("password","123456")
    let email = context.GetFormAll("email")
    let name = context.GetForm("name")
    let `from` = context.GetQuery("from")
    println("from = ${`from`}, name=${name}, password = ${password} phone=${phone}, email = ${email}")
    context.String(HttpStatusCode.STATUS_OK, "user add")
}

func formData(context: BaseHttpContext): Unit {
    let name = context.GetForm("name")
    let id = context.GetFormDefault("id", "123456")
    let number = context.GetFormDefault("number", "123444444")
    let arrays = context.GetFormAll("arrays")
    let `from` = context.GetQuery("from")
    println("from = ${`from`}, name = ${name}, id = ${id} number = ${number}, arrays = ${arrays}")
    context.String(HttpStatusCode.STATUS_OK, "formData")
}


main() {
    let engine = Engine(8888)
    let user = engine.addRouterGroup("/user")
    user.Use(GroupMiddlewareFun1, GroupMiddlewareFun2)
    user.Get("/list", userList, RouterMiddlewareFun1, RouterMiddlewareFun2)
    user.Put("/add", userAdd)
    user.Get("/get", userGet)
    user.Get("/info", userInfo)

    let test = engine.addRouterGroup("test")
    test.Post("formData", formData)
    engine.run()
}



