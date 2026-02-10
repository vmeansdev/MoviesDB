import Foundation
import OSLog

struct Log {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static let network = Logger(subsystem: subsystem, category: "Network")
}

extension URLRequest {
    func log() {
        Log.network.debug("\n - - - - - - - - - - URLRequest - - - - - - - - - - \n")
        defer { Log.network.debug("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        let urlAsString = url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlAsString)
        let method = httpMethod != nil ? "\(httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        var output = """
       \(urlAsString) \n\n
       \(method) \(path)?\(query) HTTP/1.1 \n
       HOST: \(host)\n
       """
        for (key,value) in allHTTPHeaderFields ?? [:] {
            output += "\(key): \(value) \n"
        }
        if let body = httpBody {
            output += "\n BODY: \(String(data: body, encoding: .utf8) ?? "")"
        }
        Log.network.debug("\(output)")
    }
}

extension HTTPURLResponse {
    func log(data: Data?) {
        Log.network.debug("\n - - - - - - - - - - HTTPURLResponse - - - - - - - - - - \n")
        defer { Log.network.debug("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        let urlString = url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        var output = ""
        if let urlString = urlString {
            output += "\(urlString)"
            output += "\n\n"
        }

        output += "HTTP \(statusCode) \(path)?\(query)\n"

        if let host = components?.host {
            output += "Host: \(host)\n"
        }
        for (key, value) in allHeaderFields {
            output += "\(key): \(value)\n"
        }
        if let body = data {
            output += "\n\(String(data: body, encoding: .utf8) ?? "")\n"
        }

        Log.network.debug("\(output)")
    }
}
