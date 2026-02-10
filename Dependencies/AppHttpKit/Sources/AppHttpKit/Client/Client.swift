import AnyCodable
import Foundation

public protocol Client {
    func request(_ httpRequest: Request) async throws -> Response
}

public extension Client {
    func get(_ endpoint: String, queryParams: QueryParametersConvertible? = nil, headers: [String: String]? = nil) async throws -> Data {
        try await request(.init(method: .get, url: endpoint, queryParams: queryParams?.params, headers: headers)).body
    }

    func post(
        _ endpoint: String,
        queryParams: QueryParametersConvertible? = nil,
        bodyParams: AnyEncodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> Data {
        try await request(.init(method: .post, url: endpoint, queryParams: queryParams?.params, bodyParams: bodyParams, headers: headers)).body
    }

    func put(
        _ endpoint: String,
        queryParams: QueryParametersConvertible? = nil,
        bodyParams: AnyEncodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> Data {
        try await request(.init(method: .put, url: endpoint, queryParams: queryParams?.params, bodyParams: bodyParams, headers: headers)).body
    }

    func patch(
        _ endpoint: String,
        queryParams: QueryParametersConvertible? = nil,
        bodyParams: AnyEncodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> Data {
        try await request(.init(method: .patch, url: endpoint, queryParams: queryParams?.params, bodyParams: bodyParams, headers: headers)).body
    }

    func delete(_ endpoint: String, queryParams: QueryParametersConvertible? = nil, headers: [String: String]? = nil) async throws -> Data {
        try await request(.init(method: .delete, url: endpoint, queryParams: queryParams?.params, headers: headers)).body
    }
}
