package server
from net import http.Server, http.ServerBuilder
public class Engine {
    let port: Int64
    let router: Router
    let server: Server

    public Engine(port: Int64) {
        this.port = port
        this.router = Router()
        this.server = ServerBuilder().addr("127.0.0.1").port(UInt16(this.port)).build()
    }

    public func addRouterGroup(path: String) {
        return this.router.addRouterGroup(path)
    }

    public func run() {
        for(routerGroup in this.router.getRouterGroups()) {
            let prefixPath = routerGroup.getName()
            for((routerPath, handler) in routerGroup.getRouters()) {
                let realPath = prefixPath + routerPath
                println("注册路由 ------ ${realPath}")
                this.server.distributor.register(realPath, handler)
            }
        }
        this.server.serve()
    }
}