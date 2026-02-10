import AnyCodable
import Testing
@testable import AppHttpKit

struct QueryParametersConvertibleTests {
    @Test
    func test_manyParams_shouldMatchExpectedParams() {
        let environment = Environment()
        #expect(environment.mockQuery.params == environment.mockParams)
    }

    @Test
    func test_dictionaryParams_shouldMatchExpectedParams() {
        let environment = Environment()
        #expect(environment.dictionaryQuery.params == environment.mockParams)
    }
}

private struct Environment {
    let mockQuery = MockQuery(message: "qwer", age: 30, isActive: false)
    let mockParams = ["msg": AnyEncodable("qwer"), "age": AnyEncodable(30), "isActive": AnyEncodable(false)]
    let dictionaryQuery: [String: AnyEncodable] = [
        "msg": AnyEncodable("qwer"),
        "age": AnyEncodable(30),
        "isActive": AnyEncodable(false)
    ]
}
