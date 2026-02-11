import Foundation

public struct MovieDetails: Decodable, Sendable, Equatable {
    public struct Genre: Decodable, Sendable, Equatable {
        public let id: Int
        public let name: String
    }

    public struct SpokenLanguage: Decodable, Sendable, Equatable {
        public let englishName: String
        public let iso6391: String
        public let name: String

        enum CodingKeys: String, CodingKey {
            case englishName = "english_name"
            case iso6391 = "iso_639_1"
            case name
        }
    }

    public let id: Int
    public let title: String
    public let originalTitle: String
    public let originalLanguage: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let runtime: Int?
    public let voteAverage: Double
    public let voteCount: Int
    public let genres: [Genre]
    public let spokenLanguages: [SpokenLanguage]

    public init(
        id: Int,
        title: String,
        originalTitle: String,
        originalLanguage: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        releaseDate: String?,
        runtime: Int?,
        voteAverage: Double,
        voteCount: Int,
        genres: [Genre],
        spokenLanguages: [SpokenLanguage]
    ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.originalLanguage = originalLanguage
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.genres = genres
        self.spokenLanguages = spokenLanguages
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case runtime
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genres
        case spokenLanguages = "spoken_languages"
    }
}
