package server
public class RouterGroup {
    private let name: String 
    private let routers: HashMap<String, HttpRequestHandler>

    // "/user" "user"
    RouterGroup(name: String) {
        var path = name
        if (!name.startsWith("/")) {
            path = "/" + path
        }
        this.name = path
        this.routers = HashMap<String, HttpRequestHandler>()
    }
    // "/info" "info"
    public func addRouter(name:String, handler: HttpRequestHandler) {
        var path = name
        if (!name.startsWith("/")) {
            path = "/" + path
        }
        this.routers.put(path, handler)
    }

    public func getName() {
        return this.name
    }

    public func getRouters() {
        return this.routers
    }
}