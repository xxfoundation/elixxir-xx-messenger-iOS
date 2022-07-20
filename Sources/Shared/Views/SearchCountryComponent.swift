import UIKit

public final class SearchCountryComponent: UIControl {
    let flagLabel = UILabel()
    let codeLabel = UILabel()
    let containerView = UIView()

    public init() {
        super.init(frame: .zero)

        containerView.layer.cornerRadius = 25
        containerView.backgroundColor = Asset.neutralSecondary.color

        flagLabel.text = "🇺🇸"
        codeLabel.text = "+1"
        codeLabel.textColor = Asset.neutralDisabled.color
        codeLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        addSubview(containerView)
        containerView.addSubview(flagLabel)
        containerView.addSubview(codeLabel)

        setupConstraints()
        flagLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        codeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }

        flagLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(13)
            $0.centerY.equalToSuperview()
        }

        codeLabel.snp.makeConstraints {
            $0.left.equalTo(flagLabel.snp.right).offset(10)
            $0.right.equalToSuperview().offset(-13)
            $0.centerY.equalToSuperview()
        }
    }
}
