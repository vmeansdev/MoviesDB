import Testing
@testable import PlistReader

struct PlistReaderTests {
    @Test
    func test_valueForKey_whenKeyExists_returnsValue() throws {
        let environment = Environment()
        let sut = environment.makeSUT(dictionary: [Environment.TestData.key: Environment.TestData.stringValue])
        let value: String = try sut.value(for: Environment.TestData.key)

        #expect(value == Environment.TestData.stringValue)
    }

    @Test
    func test_valueForKey_whenKeyIsMissing_throws() throws {
        let environment = Environment()
        let sut = environment.makeSUT(dictionary: [:])

        #expect(throws: PlistReader.Error.missingKey) {
            try sut.value(for: Environment.TestData.missingKey) as String
        }
    }

    @Test
    func test_valueForKey_whenValueIsWrongType_throws() throws {
        let environment = Environment()
        let sut = environment.makeSUT(dictionary: [Environment.TestData.key: Environment.TestData.numberValue])

        #expect(throws: PlistReader.Error.invalidValue) {
            try sut.value(for: Environment.TestData.key) as String
        }
    }

    @Test
    func test_valueForKey_withConvertibleString_returnsConvertedValue() throws {
        let environment = Environment()
        let sut = environment.makeSUT(dictionary: [Environment.TestData.key: Environment.TestData.stringValue])
        let value: Int = try sut.value(for: Environment.TestData.key)

        #expect(value == Environment.TestData.numberValue)
    }
}

private struct Environment {
    enum TestData {
        static let key = "TestKey"
        static let missingKey = "MissingKey"
        static let stringValue = "12345"
        static let numberValue = 12345
    }

    func makeSUT(dictionary: [String: Any]) -> PlistReader {
        PlistReader(bundle: MockBundle(infoDictionary: dictionary))
    }
}
