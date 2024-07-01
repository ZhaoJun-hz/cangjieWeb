package server
from net import http.HttpRequestDistributor, http.FuncHandler
class BaseDistrubutor <: HttpRequestDistributor {
    private var handler: HttpRequestHandler

    BaseDistrubutor() {
        this.handler = FuncHandler({httpContext => })
    }

    public func register(path: String, handler: HttpRequestHandler): Unit {
        this.handler = handler
    }

    public func distribute(path: String): HttpRequestHandler {
        return handler
    }
}