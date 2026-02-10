import Foundation

final class MockBundle: Bundle {
    private let mockInfoDictionary: [String: Any]

    init(infoDictionary: [String: Any]) {
        self.mockInfoDictionary = infoDictionary
        super.init()
    }

    override func object(forInfoDictionaryKey key: String) -> Any? {
        mockInfoDictionary[key]
    }
}
