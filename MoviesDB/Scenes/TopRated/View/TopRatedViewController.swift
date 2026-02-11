import MovieDBUI
import UIKit

@MainActor
protocol TopRatedPresentable: AnyObject {
    func displayLoading(isInitial: Bool)
    func displayMovies(_ movies: [MovieCollectionViewModel])
    func displayError(_ error: ErrorViewModel)
    func displayTitle(_ title: String)
}

final class TopRatedViewController: UIViewController {
    // MARK: - Properties
    private let interactor: TopRatedInteractorProtocol
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionLayout())
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

    // MARK: - Initialization
    init(interactor: TopRatedInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(format: String.localizable.topRatedCountTitle, 0)
        edgesForExtendedLayout = [.bottom]
        navigationItem.largeTitleDisplayMode = .automatic
        view.backgroundColor = .systemBackground
        makeLayout()
        setupDataSource()
        Task { await interactor.viewDidLoad() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset = view.safeAreaInsets.top
        if collectionView.contentInset.top != topInset {
            var insets = collectionView.contentInset
            insets.top = topInset
            insets.bottom = 0
            collectionView.contentInset = insets
            collectionView.scrollIndicatorInsets = insets
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Task { await interactor.viewWillUnload() }
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, MovieCollectionViewModel>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(MovieCollectionViewCell.self, for: indexPath)
            (cell as? MovieCollectionViewCell)?.configure(with: item)
            return cell
        }
    }
}

extension TopRatedViewController: TopRatedPresentable {
    func displayLoading(isInitial: Bool) {
        guard isInitial else { return }
        attach(LoadingViewController())
    }

    private func hideLoadingIfNeeded() {
        (children.last as? LoadingViewController)?.detach()
    }

    func displayMovies(_ movies: [MovieCollectionViewModel]) {
        hideErrorIfNeeded()
        var snapshot = NSDiffableDataSourceSnapshot<Int, MovieCollectionViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func displayError(_ error: ErrorViewModel) {
        hideErrorIfNeeded()
        attach(ErrorViewController(viewModel: error))
    }

    private func hideErrorIfNeeded() {
        hideLoadingIfNeeded()
        (children.last as? ErrorViewController)?.detach()
    }

    func displayTitle(_ title: String) {
        self.title = title
    }
}

// MARK: - Layout configuration
private extension TopRatedViewController {
    func makeCollectionLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .zero

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        section.interGroupSpacing = 0

        return UICollectionViewCompositionalLayout(section: section)
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
extension TopRatedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? CollectionViewDetachable)?.onDetach()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task { await interactor.didSelect(item: indexPath.item) }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        Task {
            if await interactor.canLoadMore(item: indexPath.item) {
                await interactor.loadMore()
            }
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension TopRatedViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let maxItem = indexPaths.map(\.item).max() ?? 0
        Task {
            if await interactor.canLoadMore(item: maxItem) {
                await interactor.loadMore()
            }
        }
    }
}
