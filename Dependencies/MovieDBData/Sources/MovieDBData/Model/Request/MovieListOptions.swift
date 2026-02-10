import AppHttpKit

public struct MovieListOptions: QueryParametersConvertible, Sendable {
    @QueryParameter(1, "page") var page: Int
    @QueryParameter("en", "language") var language: String

    public init(page: Int = 1, language: String = "en") {
        self.page = page
        self.language = language
    }
}
