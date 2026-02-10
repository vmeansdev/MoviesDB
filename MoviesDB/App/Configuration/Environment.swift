import PlistReader

enum Environment {
    static var baseURLString: String {
        ["https://", value(for: "API_BASE_URL")].joined()
    }

    static var apiKey: String {
        value(for: "API_KEY")
    }

    static var apiVersion: String {
        value(for: "API_VERSION")
    }

    private static func value<T: LosslessStringConvertible>(for key: String) -> T {
        do {
            return try PlistReader().value(for: key)
        } catch {
            fatalError("Missing or invalid Info.plist key: \(key). Error: \(error)")
        }
    }
}
