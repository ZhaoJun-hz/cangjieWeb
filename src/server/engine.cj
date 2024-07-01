package server
from net import http.Server, http.ServerBuilder, http.HttpContext, http.HttpStatusCode
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
        println("收到请求，请求路径: ${requestPath} 请求方法: ${requestMethod}")

        for(routerGroup in this.router.getRouterGroups()) {
            if(!requestPath.startsWith(routerGroup.getName())) {
                continue
            }
            let routerPath = requestPath[routerGroup.getName().size..]
            if (!routerGroup.getRouters().contains(routerPath)) {
                continue
            }
            if(!routerGroup.getRouters()[routerPath].contains(requestMethod)) {
                return FuncHandler({httpContext => 
                    httpContext.responseBuilder.status(HttpStatusCode.STATUS_METHOD_NOT_ALLOWED)
                }).handle(ctx)
            }
            return routerGroup.getRouters()[routerPath][requestMethod].handle(ctx)
        }
        return FuncHandler({ctx => 
            ctx.responseBuilder.status(HttpStatusCode.STATUS_NOT_FOUND)
        }).handle(ctx)
    }
}