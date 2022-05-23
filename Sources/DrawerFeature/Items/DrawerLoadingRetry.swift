import UIKit
import Shared
import Combine

public final class DrawerLoadingRetry: DrawerItem {
    public var retryPublisher: AnyPublisher<Void, Never> {
        retrySubject.eraseToAnyPublisher()
    }

    private let view = UIView()
    private let retryButton = UIButton()
    private let stackView = UIStackView()
    private var cancellables = Set<AnyCancellable>()
    private let activityIndicator = UIActivityIndicatorView()
    private let retrySubject = PassthroughSubject<Void, Never>()

    public var spacingAfter: CGFloat? = 0

    public init(spacingAfter: CGFloat? = 10) {
        self.spacingAfter = spacingAfter
        self.activityIndicator.style = .large
        self.activityIndicator.hidesWhenStopped = true
    }

    public func startSpinning() {
        activityIndicator.startAnimating()
        retryButton.isHidden = true
    }

    public func stopSpinning(withRetry retry: Bool) {
        guard retry else { view.isHidden = true; return }

        retryButton.isHidden = false
        activityIndicator.stopAnimating()
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setTitleColor(.red, for: .normal)

        retryButton.titleLabel?.numberOfLines = 0
        retryButton.titleLabel?.textAlignment = .center
        retryButton.titleLabel?.font = Fonts.Mulish.bold.font(size: 16.0)
    }

    public func makeView() -> UIView {
        stackView.axis = .vertical
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(retryButton)

        retryButton
            .publisher(for: .touchUpInside)
            .sink { [weak retrySubject] in retrySubject?.send() }
            .store(in: &cancellables)

        view.addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        return view
    }
}
