import UIKit
import Shared

final class SearchQRView: UIView {
    let statusLabel = UILabel()
    let imageView = UIImageView()
    let stackView = UIStackView()
    let animationView = DotAnimation()
    let overlayView = OverlayView()
    let actionButton = CapsuleButton()

    init() {
        super.init(frame: .zero)

        imageView.contentMode = .center
        actionButton.setStyle(.brandColored)

        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.textColor = Asset.neutralWhite.color
        statusLabel.font = Fonts.Mulish.regular.font(size: 14.0)

        stackView.spacing = 15
        stackView.axis = .vertical
        stackView.addArrangedSubview(animationView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(actionButton)

        imageView.isHidden = true
        actionButton.isHidden = true
        animationView.isHidden = false

        addSubview(overlayView)
        addSubview(stackView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        overlayView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(57)
            $0.right.equalToSuperview().offset(-57)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-100)
        }
    }
}
