import Kingfisher
import UIKit

public class MovieCollectionViewCell: CollectionViewCell<MovieCollectionViewModel>, CollectionViewDetachable {
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(posterImageView)
        contentView.addSubview(overlayView)
        overlayView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        setupConstraints()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        [posterImageView, overlayView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -8)
        ])
    }

    public override func configure(with viewModel: MovieCollectionViewModel) {
        posterImageView.kf.indicatorType = .activity
        if let posterURL = viewModel.posterURL {
            posterImageView.kf.setImage(with: posterURL)
        } else {
            posterImageView.image = nil
        }
        titleLabel.text = viewModel.title
        titleLabel.accessibilityLabel = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        subtitleLabel.accessibilityLabel = viewModel.subtitle
    }

    public func onDetach() {
        posterImageView.kf.cancelDownloadTask()
    }
}
