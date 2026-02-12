import Foundation

public actor ResponseCache {
    public struct Entry: Codable, Sendable {
        public let expiry: Date
        public let code: Int
        public let headers: [String: String]
        public let body: Data

        public init(expiry: Date, code: Int, headers: [String: String], body: Data) {
            self.expiry = expiry
            self.code = code
            self.headers = headers
            self.body = body
        }
    }

    private let fileManager: FileManager
    private let directoryURL: URL
    private var memory: [String: Entry] = [:]

    public init(
        fileManager: FileManager = .default,
        directoryName: String = "MovieDBResponseCache"
    ) {
        self.fileManager = fileManager
        if let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            directoryURL = caches.appendingPathComponent(directoryName, isDirectory: true)
        } else {
            directoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(directoryName, isDirectory: true)
        }
    }

    public func entry(for key: String) -> Entry? {
        if let cached = memory[key], !isExpired(cached) {
            return cached
        }
        if let cached = loadFromDisk(for: key), !isExpired(cached) {
            memory[key] = cached
            return cached
        }
        remove(for: key)
        return nil
    }

    public func set(_ entry: Entry, for key: String) {
        memory[key] = entry
        saveToDisk(entry, for: key)
    }

    public func remove(for key: String) {
        memory.removeValue(forKey: key)
        removeFromDisk(for: key)
    }

    private func isExpired(_ entry: Entry) -> Bool {
        entry.expiry <= Date()
    }

    private func ensureDirectory() {
        guard !fileManager.fileExists(atPath: directoryURL.path) else { return }
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    private func fileURL(for key: String) -> URL {
        directoryURL.appendingPathComponent("\(hashKey(key)).json")
    }

    private func loadFromDisk(for key: String) -> Entry? {
        let url = fileURL(for: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Entry.self, from: data)
    }

    private func saveToDisk(_ entry: Entry, for key: String) {
        ensureDirectory()
        let url = fileURL(for: key)
        guard let data = try? JSONEncoder().encode(entry) else { return }
        try? data.write(to: url, options: [.atomic])
    }

    private func removeFromDisk(for key: String) {
        let url = fileURL(for: key)
        try? fileManager.removeItem(at: url)
    }

    private func hashKey(_ key: String) -> String {
        if #available(iOS 13.0, *) {
            return SHA256Hasher.hex(key)
        }
        return String(key.hashValue)
    }
}
