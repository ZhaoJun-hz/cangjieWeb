package server
from net import http.HttpRequestHandler
from std import collection.HashMap, collection.ArrayList

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