import Foundation

public class HttpClient: Client {
    private let baseURL: String
    private let session: URLSession
    private let urlEncoder: ParameterEncoder
    private let urlBuilder: URLBuilder
    private let bodyEncoders: [ParameterEncoder]

    public init(
        baseURL: String,
        timeOut: TimeInterval? = nil,
        session: URLSession? = nil,
        urlEncoder: ParameterEncoder = URLParameterEncoder(),
        urlBuilder: URLBuilder = HttpURLBuilder(),
        bodyEncoders: [ParameterEncoder] = [
            JSONParameterEncoder(),
            URLParameterEncoder(),
            MultipartParameterEncoder(jsonParameterEncoder: JSONParameterEncoder()),
            DataParameterEncoder()
        ]
    ) {
        self.baseURL = baseURL
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            if let timeOut {
                configuration.timeoutIntervalForRequest = timeOut
            }
            self.session = URLSession(configuration: configuration)
        }
        self.urlEncoder = urlEncoder
        self.urlBuilder = urlBuilder
        self.bodyEncoders = bodyEncoders
    }

    public func request(_ httpRequest: Request) async throws -> Response {
        let url = try urlBuilder.buildURL(baseURL: baseURL, request: httpRequest)
        var request = URLRequest(url: url)
        request.httpMethod = httpRequest.method.uppercased
        request.httpBody = try buildRequestBody(httpRequest)
        httpRequest.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        #if DEBUG
        request.log()
        #endif
        var httpResponse = Response(request: httpRequest, headers: [:], code: 0, body: Data())
        do {
            let (data, response) = try await session.data(for: request)
            #if DEBUG
            (response as? HTTPURLResponse)?.log(data: data)
            #endif
            httpResponse = Response(request: httpRequest, response: response, body: data)
        } catch let error {
            guard (error as NSError?)?.code != NSURLErrorTimedOut else {
                throw ClientError.timeout
            }
            throw ClientError.network(response: httpResponse, error: error)
        }
        return httpResponse
    }

    private func buildRequestBody(_ request: Request) throws -> Data? {
        guard [.post, .put, .patch].contains(request.method), let params = request.bodyParams else {
            return nil
        }
        guard let encoder = encoder(for: request) else {
            throw ClientError.encoderNotFound
        }
        return try encoder.dataEncode(params)
    }

    private func encoder(for request: Request) -> ParameterEncoder? {
        guard let type = request.contentType else { return bodyEncoders.first }
        return bodyEncoders.first(where: { $0.contentType(request: request).starts(with: type) })
    }
}
