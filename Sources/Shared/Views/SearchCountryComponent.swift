import UIKit

public final class SearchCountryComponent: UIControl {
    let flagLabel = UILabel()
    let prefixLabel = UILabel()
    let containerView = UIView()

    public init() {
        super.init(frame: .zero)

        containerView.layer.cornerRadius = 25
        containerView.backgroundColor = Asset.neutralSecondary.color

        flagLabel.text = "🇺🇸"
        prefixLabel.text = "+1"
        prefixLabel.textColor = Asset.neutralDisabled.color
        prefixLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        addSubview(containerView)
        containerView.addSubview(flagLabel)
        containerView.addSubview(prefixLabel)

        containerView.isUserInteractionEnabled = false

        setupConstraints()
        flagLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        prefixLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) { nil }

    public func setFlag(_ flag: String, prefix: String) {
        flagLabel.text = flag
        prefixLabel.text = prefix
    }

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

        prefixLabel.snp.makeConstraints {
            $0.left.equalTo(flagLabel.snp.right).offset(10)
            $0.right.equalToSuperview().offset(-13)
            $0.centerY.equalToSuperview()
        }
    }
}
