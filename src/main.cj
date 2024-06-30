from net import http.ServerBuilder, http.FuncHandler
import server.Router, server.Engine
main() {
    let engine = Engine(8888)
    let user = engine.addRouterGroup("user")
    user.addRouter("info", FuncHandler({httpContext => 
        println("user info come here")
        httpContext.responseBuilder.body("hello this is user info")
    }))

    user.addRouter("list", FuncHandler({httpContext => 
        println("user list come here")
        httpContext.responseBuilder.body("hello this is user list")
    }))

    let product = engine.addRouterGroup("product")
    product.addRouter("info", FuncHandler({httpContext => 
        println("product info come here")
        httpContext.responseBuilder.body("hello this is product info")
    }))

    product.addRouter("list", FuncHandler({httpContext => 
        println("product list come here")
        httpContext.responseBuilder.body("hello this is product list")
    }))

    engine.run()
}
