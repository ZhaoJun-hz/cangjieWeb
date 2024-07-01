package server
public class RouterGroup {
    private let name: String 
    private let routers: HashMap<String, HashMap<String, HttpRequestHandler>>

    RouterGroup(name: String) {
        var path = name
        if (!name.startsWith("/")) {
            path = "/" + path
        }
        this.name = path
        this.routers = HashMap<String, HashMap<String, HttpRequestHandler>>()
    }

    public func Get(name:String, handler: HttpRequestHandler) {
        addRouter(name, "GET", handler)
    }

    public func Post(name:String, handler: HttpRequestHandler) {
        addRouter(name, "POST", handler)
    }

    public func Delete(name:String, handler: HttpRequestHandler) {
        addRouter(name, "DELETE", handler)
    }

    public func Put(name:String, handler: HttpRequestHandler) {
        addRouter(name, "PUT", handler)
    }

    private func addRouter(name:String, method: String,  handler: HttpRequestHandler) {
        var path = name
        if (!name.startsWith("/")) {
            path = "/" + path
        }
        if (!this.routers.contains(path)) {
            routers[path] = HashMap<String, HttpRequestHandler>()
        }
        if (!this.routers[path].contains(method)) {
            println("路由${path} method = ${method} 已经注册过了")
        }
        this.routers[path].put(method, handler)
    }

    public func getName() {
        return this.name
    }

    public func getRouters() {
        return this.routers
    }
}