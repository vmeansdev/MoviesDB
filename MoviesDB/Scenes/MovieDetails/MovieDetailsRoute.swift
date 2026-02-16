import MovieDBData

struct MovieDetailsRoute: Hashable {
    let id: Int
    let viewModel: MovieDetailsViewModel

    init(movie: Movie, viewModel: MovieDetailsViewModel) {
        self.id = movie.id
        self.viewModel = viewModel
    }

    static func == (lhs: MovieDetailsRoute, rhs: MovieDetailsRoute) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
