macro package cangjieWeb.macros
import std.ast.*
import serialization.serialization.*
import encoding.json.*
import std.collection.*

class VarDeclVisitor <: Visitor {
    private let varDecls: ArrayList<VarDecl> = ArrayList<VarDecl>()

    public func getAllVarDecls(): Array<VarDecl> {
        return varDecls.toArray()
    }

    public override func visit(VarDecl: VarDecl) {
        varDecls.append(VarDecl)
        breakTraverse()
        return
    }
}

class JsonFiledConvert {
    protected let varId: Token
    protected let varType: TypeNode

    JsonFiledConvert(vd: VarDecl) {
        this.varId = vd.identifier
        this.varType = vd.declType
    }

    public func generateSerialize(): Tokens {
        quote(
            dms.add(field<$(varType)>($(varId.value), $(varId)))
        )
    }
    
    public func generateDeserialize(): Tokens {
        quote(
            obj.$(varId) = $(varType).deserialize(dms.get($(varId.value)))
        )
    }
}

class JsonConvert {
    let classId: Token
    let fields: ArrayList<JsonFiledConvert>

    JsonConvert(classId: Token, vars: Array<VarDecl>) {
        this.classId = classId
        this.fields = ArrayList<JsonFiledConvert>()
        for(vd in vars) {
            this.fields.append(JsonFiledConvert(vd))
        }
    }
    public func generateSerialize(): Tokens {
        var serFields = Tokens()
        for(f in fields) {
            serFields += f.generateSerialize()
        }


        quote(
            public func serialize(): DataModel {
                var dms = DataModelStruct()
                $(serFields)
                dms
            }
        )
    }

    public func generateDeserialize(): Tokens {
        var deserFields = Tokens()
        for(f in fields) {
            deserFields += f.generateDeserialize()
        }

        quote(
            public static func deserialize(dm: DataModel): $(classId) {
                let dms = match(dm) {
                    case data: DataModelStruct => data
                    case _ => throw Exception("this data is not DataModelStruct")
                }

                var obj = $(classId)()
                $(deserFields)
                obj
            }

        )
    }
}

public macro Json(input: Tokens): Tokens {
    let s: Decl = parseDecl(input)
    var jsonConvert: JsonConvert
    match (s) {
        case d: ClassDecl =>
            let ident = d.identifier
            let visitor = VarDeclVisitor()
            d.traverse(visitor)
            jsonConvert = JsonConvert(ident, visitor.getAllVarDecls())
        case d: StructDecl =>
            let ident = d.identifier
            let visitor = VarDeclVisitor()
            d.traverse(visitor)
            jsonConvert = JsonConvert(ident, visitor.getAllVarDecls())
        case _ => throw Exception("Json only using for struct or class")
    }

    let serFunc = jsonConvert.generateSerialize()
    let deserFunc = jsonConvert.generateDeserialize()

    input + quote(
        extend $(jsonConvert.classId) <: Serializable<$(jsonConvert.classId)> {
            $(serFunc)
            $(deserFunc)
        }
    )
}