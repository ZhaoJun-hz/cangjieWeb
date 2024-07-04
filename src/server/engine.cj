package server
from net import http.Server, http.ServerBuilder, http.HttpContext, http.HttpStatusCode
public type HandlerFunc = (BaseHttpContext) -> Unit
public class Engine {
    let port: Int64
    let router: Router
    let server: Server

    public Engine(port: Int64) {
        this.port = port
        this.router = Router()
        this.server = ServerBuilder().addr("127.0.0.1")
            .port(UInt16(this.port))
            .distributor(BaseDistrubutor())
            .build()
    }

    public func addRouterGroup(path: String) {
        return this.router.addRouterGroup(path)
    }

    public func run() {
        this.server.distributor.register("/", handler)
        this.server.serve()
    }

    func handler(ctx: HttpContext) {
        let requestMethod = ctx.request.method
        let requestPath = ctx.request.url.path
        println("receive request requestPath : ${requestPath} request method: ${requestMethod}")

        for(routerGroup in this.router.getRouterGroups()) {
            if(!requestPath.startsWith(routerGroup.getName())) {
                continue
            }
            // /info/:id/:name /info/1/1000
            let routerPath = requestPath[routerGroup.getName().size..]
            let result = routerGroup.treeNode.get(routerPath)
            match (result) {
                case Some(treeNode) => 
                    // 匹配一下请求方式
                    println("${routerPath}  ${treeNode.fullPath}")
                    if (routerGroup.getRouters()[treeNode.fullPath].contains(requestMethod)) {
                        // 请求方式匹配
                        let handler = routerGroup.getRouters()[treeNode.fullPath][requestMethod]
                        return FuncHandler({httpContext =>
                            let baseHttpContext = BaseHttpContext(httpContext)
                            routerGroup.invokeHandler(treeNode.fullPath, requestMethod, handler, baseHttpContext)
                        }).handle(ctx)
                    } else {
                        // 请求方式不匹配
                            return FuncHandler({httpContext => 
                                httpContext.responseBuilder.status(HttpStatusCode.STATUS_METHOD_NOT_ALLOWED)
                            }).handle(ctx)
                    }
                case None => println("not found router ${routerPath}")
                
            }
        }
        return FuncHandler({ctx => 
            ctx.responseBuilder.status(HttpStatusCode.STATUS_NOT_FOUND)
        }).handle(ctx)
    }
}