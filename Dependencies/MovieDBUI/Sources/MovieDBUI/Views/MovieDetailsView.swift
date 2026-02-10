import Kingfisher
import UIKit

public class MovieDetailsView: UIView, ConfigurableView, DetachableView {
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let overviewLabel = UILabel()
    private let containerView = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(scrollView)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        scrollView.addSubview(imageView)
        scrollView.addSubview(containerView)

        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        containerView.addSubview(stackView)

        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.numberOfLines = 0
        overviewLabel.font = UIFont.preferredFont(forTextStyle: .body)
        overviewLabel.adjustsFontForContentSizeCategory = true
        overviewLabel.numberOfLines = 0

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(overviewLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        [scrollView, imageView, containerView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),

            containerView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
        ])
    }

    public func configure(with viewModel: MovieDetailsViewModel) {
        imageView.kf.indicatorType = .activity
        if let imageURL = viewModel.imageURL {
            imageView.kf.setImage(with: imageURL, placeholder: viewModel.placeholderImage)
        } else {
            imageView.image = viewModel.placeholderImage
        }
        titleLabel.text = viewModel.title
        titleLabel.accessibilityLabel = Constants.titleAccessibilityLabel
        titleLabel.accessibilityValue = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        subtitleLabel.accessibilityLabel = Constants.subtitleAccessibilityLabel
        subtitleLabel.accessibilityValue = viewModel.subtitle
        if let overview = viewModel.overview {
            overviewLabel.isHidden = false
            overviewLabel.text = overview
            overviewLabel.accessibilityLabel = Constants.overviewAccessibilityLabel
            overviewLabel.accessibilityValue = overview
        } else {
            overviewLabel.isHidden = true
        }
    }

    public func onDetach() {
        imageView.kf.cancelDownloadTask()
    }

    private enum Constants {
        static let titleAccessibilityLabel = "Movie title"
        static let subtitleAccessibilityLabel = "Movie subtitle"
        static let overviewAccessibilityLabel = "Movie overview"
    }
}
