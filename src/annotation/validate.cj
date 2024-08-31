package cangjieWeb.annotation

@Annotation[target: [MemberVariable]]
public class Validate {
    private let validate: String
    public const init(validate: String) {
        this.validate = validate
    }

    public func getValidate() {
        return this.validate
    }
}