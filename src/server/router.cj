package server
from net import http.HttpRequestHandler
from std import collection.HashMap

public class Router{
    private let routers: HashMap<String, HttpRequestHandler>

    public Router() {
        this.routers = HashMap<String, HttpRequestHandler>()
    }

    public func addRouter(path: String, handler: HttpRequestHandler) {
        this.routers.put(path, handler)
    }

    func getRouters() {
        return this.routers
    }
}