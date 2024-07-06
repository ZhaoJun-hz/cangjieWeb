package server
from serialization import serialization.*
from encoding import json.*
public class BaseHttpContext {
    private let context: http.HttpContext 

    BaseHttpContext(context: http.HttpContext ) {
        this.context = context
    }

    public func HTML(status: UInt16, content: String) {
        this.context.responseBuilder.header("content-type", "text/html; charset=utf-8").status(status).body(content)
    }

    public func String(status: UInt16, content: String) {
        this.context.responseBuilder.status(status).body(content)
    }

    public func Json<T>(status: UInt16, data: T) where T <: Serializable<T> {
         this.context.responseBuilder.header("content-type", "text/json; charset=utf-8").status(status)
         .body(data.serialize().toJson().asObject().toJsonString())
    }
}