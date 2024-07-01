from net import http.ServerBuilder, http.FuncHandler
import server.Router, server.Engine
main() {
    let engine = Engine(8888)
    let user = engine.addRouterGroup("user")
    user.Get("info", FuncHandler({httpContext => 
        println("user info come here")
        httpContext.responseBuilder.body("hello this is user info")
    }))
    user.Post("info", FuncHandler({httpContext => 
        println("post user info come here")
        httpContext.responseBuilder.body("hello this is user info post method")
    }))

    user.Get("list", FuncHandler({httpContext => 
        println("user list come here")
        httpContext.responseBuilder.body("hello this is user list")
    }))

    let product = engine.addRouterGroup("product")
    product.Post("info", FuncHandler({httpContext => 
        println("product info come here")
        httpContext.responseBuilder.body("hello this is product info")
    }))

    product.Put("list", FuncHandler({httpContext => 
        println("product list come here")
        httpContext.responseBuilder.body("hello this is product list")
    }))

    engine.run()
}
