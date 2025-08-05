package cangjieWeb.server
import std.collection.{HashMap, ArrayList}

type MiddlewaresFunc = (HandlerFunc) -> HandlerFunc

public class RouterGroup {
    private let name: String 
    private let routers: HashMap<String, HashMap<String, HandlerFunc>>
    let treeNode: TreeNode
    // 针对路由分组
    let middlewares: ArrayList<MiddlewaresFunc>
    // 针对某个路由的                       routerPath      request method       
    let handlerMethodMiddlewares:  HashMap<String, HashMap<String, ArrayList<MiddlewaresFunc>>>


    RouterGroup(name: String) {
        var path = name
        if (!name.startsWith("/")) {
            path = "/" + path
        }
        this.name = path
        this.routers = HashMap<String, HashMap<String, HandlerFunc>>()
        this.treeNode = TreeNode("/", "")
        this.middlewares = ArrayList<MiddlewaresFunc>()
        this.handlerMethodMiddlewares = HashMap<String, HashMap<String, ArrayList<MiddlewaresFunc>>>()
    }

    public func Use(middlewares: Array<MiddlewaresFunc>) {
        this.middlewares.add(all: middlewares)
    }

    public func Get(name:String, handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        addRouter(name, "GET", handler, middlewares)
    }

    public func Post(name:String, handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        addRouter(name, "POST", handler, middlewares)
    }

    public func Delete(name:String, handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        addRouter(name, "DELETE", handler, middlewares)
    }

    public func Put(name:String, handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        addRouter(name, "PUT", handler, middlewares)
    }

    private func addRouter(name:String, method: String,  handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        var path = name
        if (!name.startsWith("/")) {
            path = "/" + path
        }
        if (!this.routers.contains(path)) {
            routers[path] = HashMap<String, HandlerFunc>()
            handlerMethodMiddlewares[path] = HashMap<String, ArrayList<MiddlewaresFunc>>()
        }
        if (this.routers[path].contains(method)) {
            println("groupPath = ${this.getName()} routerPath = ${path} method = ${method} already register")
        }
        this.routers[path].add(method, handler)
        if (!handlerMethodMiddlewares[path].contains(method)) {
            handlerMethodMiddlewares[path].add(method, ArrayList<MiddlewaresFunc>())
        }
        // 给TreeNode 添加数据
        this.treeNode.put(path)
        handlerMethodMiddlewares[path][method].add(all: middlewares)
    }

    public func invokeHandler(routerPath: String, method: String, handler: HandlerFunc, ctx: BaseHttpContext) {
        var newHandler = handler
        for (middleware in this.middlewares) {
            newHandler = middleware(newHandler)
        }
        if(handlerMethodMiddlewares.contains(routerPath) && handlerMethodMiddlewares[routerPath].contains(method)) {
            let handlerMiddlewares =  handlerMethodMiddlewares[routerPath][method]
            for (middleware in handlerMiddlewares) {
                newHandler = middleware(newHandler)
            }
        }
        newHandler(ctx)
    }

    public func getName() {
        return this.name
    }

    public func getRouters() {
        return this.routers
    }
}