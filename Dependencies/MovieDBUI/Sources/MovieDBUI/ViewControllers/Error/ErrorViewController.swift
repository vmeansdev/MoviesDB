import UIKit

public struct ErrorViewModel: Equatable {
    let errorMessage: String
    let retryAction: (() -> Void)?

    public init(errorMessage: String, retryAction: (() -> Void)?) {
        self.errorMessage = errorMessage
        self.retryAction = retryAction
    }

    public static func == (lhs: ErrorViewModel, rhs: ErrorViewModel) -> Bool {
        lhs.errorMessage == rhs.errorMessage
    }
}

public class ErrorViewController: UIViewController {
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [messageLabel, retryButton, closeButton])
        view.axis = .vertical
        view.spacing = 16
        return view
    }()
    private let viewModel: ErrorViewModel

    public init(viewModel: ErrorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        makeLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    @objc private func retryButtonTapped() {
        viewModel.retryAction?()
        dismiss(animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func configureUI() {
        messageLabel.text = viewModel.errorMessage
        retryButton.isHidden = viewModel.retryAction == nil
        closeButton.isHidden = viewModel.retryAction != nil
    }

    private func makeLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}
