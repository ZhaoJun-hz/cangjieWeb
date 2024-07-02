from net import http.ServerBuilder, http.FuncHandler
import server.Router, server.Engine
main() {
    let engine = Engine(8888)
    let user = engine.addRouterGroup("/user")
    user.Get("/list", FuncHandler({httpContext => 
        println("user list")
        httpContext.responseBuilder.body("user list")
    }))
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
