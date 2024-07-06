from net import http.ServerBuilder, http.FuncHandler, http.HttpRequestHandler, http.HttpStatusCode
import server.Router, server.Engine, server.HandlerFunc, server.BaseHttpContext
import model.User

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

func userAdd(context: BaseHttpContext): Unit{
    println("user add")
    context.String(HttpStatusCode.STATUS_OK, "user add")
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

main() {
    let engine = Engine(8888)
    let user = engine.addRouterGroup("/user")
    user.Use(GroupMiddlewareFun1, GroupMiddlewareFun2)
    user.Get("/list", userList, RouterMiddlewareFun1, RouterMiddlewareFun2)
    user.Put("/add", userAdd)
    user.Get("/get", userGet)
    engine.run()
}
