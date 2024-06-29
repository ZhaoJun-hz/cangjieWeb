package server
from net import http.Server, http.ServerBuilder
public class Engine {
    let port: Int64
    let router: Router
    let server: Server

    public Engine(port: Int64, router: Router) {
        this.port = port
        this.router = router
        this.server = ServerBuilder().addr("127.0.0.1").port(UInt16(this.port)).build()
    }

    public func run() {
        for((path,handler) in this.router.getRouters()) {
            println("注册路由 ------ ${path}")
            this.server.distributor.register(path, handler)
        }
        this.server.serve()
    }
}