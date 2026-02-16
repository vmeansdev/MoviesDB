import Foundation
import OSLog

struct Log {
    private static let subsystem = Bundle.module.bundleIdentifier!

    static let network = Logger(subsystem: subsystem, category: "Network")
    static let storage = Logger(subsystem: subsystem, category: "LocalStorage")
}
