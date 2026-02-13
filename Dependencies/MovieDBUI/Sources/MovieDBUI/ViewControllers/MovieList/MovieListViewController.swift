import UIKit

@MainActor
public protocol MovieListPresentable: AnyObject {
    func displayLoading(isInitial: Bool)
    func displayMovies(_ movies: [MovieCollectionViewModel])
    func displayError(_ error: ErrorViewModel)
    func displayTitle(_ title: String)
}

open class MovieListViewController: UIViewController {
    private enum Constants {
        static let gridMinItemWidth: CGFloat = 200
        static let maxGridColumns = 6
        static let minGridColumns = 2
    }

    private enum LayoutStyle: Equatable {
        case list
        case grid(columns: Int)
    }

    // MARK: - Properties
    public let interactor: MovieListInteractorProtocol
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionLayout(for: .list))
        view.isPrefetchingEnabled = true
        view.prefetchDataSource = self
        view.backgroundColor = .systemBackground
        view.contentInsetAdjustmentBehavior = .never
        view.delegate = self
        view.dataSource = dataSource
        view.registerCell(MovieCollectionViewCell.self)
        return view
    }()
    private var dataSource: UICollectionViewDiffableDataSource<Int, MovieCollectionViewModel>!
    private var layoutStyle: LayoutStyle = .list

    // MARK: - Initialization
    public init(interactor: MovieListInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides
    open var initialTitle: String { "" }

    // MARK: - Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        title = initialTitle
        edgesForExtendedLayout = [.bottom]
        navigationItem.largeTitleDisplayMode = .automatic
        view.backgroundColor = .systemBackground
        makeLayout()
        setupDataSource()
        registerForTraitChanges([UITraitHorizontalSizeClass.self, UITraitUserInterfaceIdiom.self]) { [weak self] (_: MovieListViewController, _: UITraitCollection) in
            self?.updateLayoutIfNeeded()
        }
        Task { await interactor.viewDidLoad() }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutIfNeeded()
        let topInset = view.safeAreaInsets.top
        if collectionView.contentInset.top != topInset {
            var insets = collectionView.contentInset
            insets.top = topInset
            insets.bottom = 0
            collectionView.contentInset = insets
            collectionView.scrollIndicatorInsets = insets
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Task { await interactor.viewWillUnload() }
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, MovieCollectionViewModel>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(MovieCollectionViewCell.self, for: indexPath)
            if let movieCell = cell as? MovieCollectionViewCell {
                movieCell.configure(with: item)
                movieCell.onToggleWatchlist = { [weak self] in
                    Task { await self?.interactor.didToggleWatchlist(item: indexPath.item) }
                }
            }
            return cell
        }
    }
}

extension MovieListViewController: MovieListPresentable {
    public func displayLoading(isInitial: Bool) {
        guard isInitial else { return }
        attach(LoadingViewController())
    }

    private func hideLoadingIfNeeded() {
        (children.last as? LoadingViewController)?.detach()
    }

    public func displayMovies(_ movies: [MovieCollectionViewModel]) {
        hideErrorIfNeeded()
        let currentSnapshot = dataSource.snapshot()
        var snapshot = NSDiffableDataSourceSnapshot<Int, MovieCollectionViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies)
        if currentSnapshot.numberOfItems == 0 {
            dataSource.apply(snapshot, animatingDifferences: true)
            return
        }

        let currentItems = Dictionary(uniqueKeysWithValues: currentSnapshot.itemIdentifiers.map { ($0.id, $0) })
        let changed = movies.compactMap { item -> MovieCollectionViewModel? in
            guard let previous = currentItems[item.id] else { return item }
            return previous == item ? nil : item
        }

        snapshot.reconfigureItems(changed)
        let currentIds = currentSnapshot.itemIdentifiers.map(\.id)
        let newIds = movies.map(\.id)
        let shouldAnimate = currentIds != newIds
        dataSource.apply(snapshot, animatingDifferences: shouldAnimate)
    }

    public func displayError(_ error: ErrorViewModel) {
        hideErrorIfNeeded()
        attach(ErrorViewController(viewModel: error))
    }

    private func hideErrorIfNeeded() {
        hideLoadingIfNeeded()
        (children.last as? ErrorViewController)?.detach()
    }

    public func displayTitle(_ title: String) {
        self.title = title
    }
}

// MARK: - Layout configuration
private extension MovieListViewController {
    private func makeCollectionLayout(for style: LayoutStyle) -> UICollectionViewLayout {
        let columns = columnsCount(for: style)
        let itemWidthFraction = 1.0 / CGFloat(columns)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(itemWidthFraction),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .zero

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(250))
        let items = Array(repeating: item, count: columns)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        section.interGroupSpacing = 0

        return UICollectionViewCompositionalLayout(section: section)
    }

    func updateLayoutIfNeeded() {
        let nextStyle = resolveLayoutStyle()
        guard nextStyle != layoutStyle else { return }
        layoutStyle = nextStyle
        collectionView.setCollectionViewLayout(makeCollectionLayout(for: nextStyle), animated: false)
    }

    private func resolveLayoutStyle() -> LayoutStyle {
        if shouldUseGridLayout() {
            let columns = gridColumnsCount()
            return .grid(columns: columns)
        }
        return .list
    }

    func shouldUseGridLayout() -> Bool {
        if traitCollection.horizontalSizeClass == .regular {
            return true
        }
        if traitCollection.userInterfaceIdiom == .phone {
            return view.bounds.width > view.bounds.height
        }
        return false
    }

    func gridColumnsCount() -> Int {
        if traitCollection.userInterfaceIdiom == .phone {
            return 3
        }
        let availableWidth = max(0, view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right)
        let rawColumns = Int(availableWidth / Constants.gridMinItemWidth)
        let clamped = min(Constants.maxGridColumns, max(Constants.minGridColumns, rawColumns))
        return clamped
    }

    private func columnsCount(for style: LayoutStyle) -> Int {
        switch style {
        case .list:
            return 1
        case .grid(let columns):
            return columns
        }
    }

    func makeLayout() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

// MARK: - UICollectionViewDelegate
extension MovieListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? CollectionViewDetachable)?.onDetach()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task { await interactor.didSelect(item: indexPath.item) }
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        Task {
            if await interactor.canLoadMore(item: indexPath.item) {
                await interactor.loadMore()
            }
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension MovieListViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let maxItem = indexPaths.map(\.item).max() ?? 0
        Task {
            if await interactor.canLoadMore(item: maxItem) {
                await interactor.loadMore()
            }
        }
    }
}
