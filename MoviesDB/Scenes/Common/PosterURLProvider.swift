import Foundation

protocol PosterURLProviding: Sendable {
    nonisolated func makePosterURL(path: String?) -> URL?
    nonisolated func makeBackdropURL(path: String?) -> URL?
    nonisolated func makePosterOrBackdropURL(posterPath: String?, backdropPath: String?) -> URL?
}

struct PosterURLProvider: PosterURLProviding {
    private let posterBaseURL: String
    private let backdropBaseURL: String

    nonisolated init(imageBaseURLString: String) {
        posterBaseURL = "\(imageBaseURLString)/t/p/w500"
        backdropBaseURL = "\(imageBaseURLString)/t/p/w780"
    }

    nonisolated func makePosterURL(path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: "\(posterBaseURL)\(path)")
    }

    nonisolated func makeBackdropURL(path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: "\(backdropBaseURL)\(path)")
    }

    nonisolated func makePosterOrBackdropURL(posterPath: String?, backdropPath: String?) -> URL? {
        makePosterURL(path: posterPath) ?? makeBackdropURL(path: backdropPath)
    }
}
