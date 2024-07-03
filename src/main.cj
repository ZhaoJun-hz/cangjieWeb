from net import http.ServerBuilder, http.FuncHandler, http.HttpRequestHandler
import server.Router, server.Engine

func GroupMiddlewareFun1(next: http.HttpRequestHandler): http.HttpRequestHandler {
    return FuncHandler() { ctx=>
        println("pre GroupMiddlewareFun1")
        next.handle(ctx)
        println("post GroupMiddlewareFun1")
    }
}

func GroupMiddlewareFun2(next: http.HttpRequestHandler): http.HttpRequestHandler {
    return FuncHandler() { ctx=>
        println("pre GroupMiddlewareFun2")
        next.handle(ctx)
        println("post GroupMiddlewareFun2")
    }
}


func RouterMiddlewareFun1(next: http.HttpRequestHandler): http.HttpRequestHandler {
    return FuncHandler() { ctx=>
        println("pre RouterMiddlewareFun1")
        next.handle(ctx)
        println("post RouterMiddlewareFun1")
    }
}

func RouterMiddlewareFun2(next: http.HttpRequestHandler): http.HttpRequestHandler {
    return FuncHandler() { ctx=>
        println("pre RouterMiddlewareFun2")
        next.handle(ctx)
        println("post RouterMiddlewareFun2")
    }
}

main() {
    let engine = Engine(8888)
    let user = engine.addRouterGroup("/user")
    user.Use(GroupMiddlewareFun1, GroupMiddlewareFun2)
    user.Get("/list", FuncHandler({httpContext => 
        println("user list")
        httpContext.responseBuilder.body("user list")
    }), RouterMiddlewareFun1, RouterMiddlewareFun2)
    user.Put("/add", FuncHandler({httpContext => 
        println("user add")
        httpContext.responseBuilder.body("user add")
    }))
   
    let product = engine.addRouterGroup("/product")
    product.Get("/:id/:name", FuncHandler({httpContext => 
        println("product :id :name")
        httpContext.responseBuilder.body("product :id :name")
    }))
  
    let dept = engine.addRouterGroup("/dept")
    dept.Get("/*", FuncHandler({httpContext => 
        println("dept *")
        httpContext.responseBuilder.body("dept *")
    }))
    
    let menu = engine.addRouterGroup("/menu")
    menu.Get("/*/info", FuncHandler({httpContext => 
        println("menu * info")
        httpContext.responseBuilder.body("menu * info")
    }))
    engine.run()
}
