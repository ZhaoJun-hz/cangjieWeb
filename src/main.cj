from net import http.ServerBuilder, http.FuncHandler
import server.Router, server.Engine
main() {
    let router = Router()

    router.addRouter("/user/info", FuncHandler({httpContext => 
        println("user info come here")
        httpContext.responseBuilder.body("hello this is user info")
    }))

    router.addRouter("/user/list", FuncHandler({httpContext => 
        println("user list come here")
        httpContext.responseBuilder.body("hello this is user list")
    }))

    let engine = Engine(8888, router)
    engine.run()
}
