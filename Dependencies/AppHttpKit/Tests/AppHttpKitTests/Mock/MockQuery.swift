import AppHttpKit

struct MockQuery: QueryParametersConvertible {
    @QueryParameter("hello", "msg") var message: String
    @QueryParameter(20, "age") var age: Int
    @QueryParameter(true, "isActive") var isActive: Bool

    init(message: String, age: Int, isActive: Bool) {
        self.message = message
        self.age = age
        self.isActive = isActive
    }
}
