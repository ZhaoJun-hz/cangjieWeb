package cangjieWeb.server
import net.http.{HttpRequestHandler}
import std.collection.{HashMap, ArrayList}

public class Router{
    private let routerGroups: ArrayList<RouterGroup>

    public Router() {
        this.routerGroups = ArrayList<RouterGroup>()
    }

    public func addRouterGroup(path: String) {
        let routerGroup = RouterGroup(path)
        this.routerGroups.append(routerGroup)
        return routerGroup
    }

    func getRouterGroups() {
        return this.routerGroups
    }
}