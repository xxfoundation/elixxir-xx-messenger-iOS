import UIKit
import Shared

final class RadioButton: UIControl {
    private let filledView = UIView()
    private let containerView = UIView()

    init() {
        super.init(frame: .zero)

        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        containerView.layer.borderColor = UIColor.gray.cgColor

        filledView.isHidden = true
        filledView.layer.cornerRadius = 10
        filledView.layer.masksToBounds = true
        filledView.backgroundColor = Asset.brandPrimary.color

        containerView.isUserInteractionEnabled = false
        filledView.isUserInteractionEnabled = false

        addSubview(containerView)
        containerView.addSubview(filledView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func set(enabled: Bool) {
        filledView.isHidden = !enabled
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.width.equalTo(30)
            $0.height.equalTo(30)
            $0.top.equalToSuperview().offset(5)
            $0.left.equalToSuperview().offset(5)
            $0.right.equalToSuperview().offset(-5)
            $0.bottom.equalToSuperview().offset(-5)
        }

        filledView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.left.equalToSuperview().offset(5)
            $0.right.equalToSuperview().offset(-5)
            $0.bottom.equalToSuperview().offset(-5)
        }
    }
}
