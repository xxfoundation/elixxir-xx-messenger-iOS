import UIKit

public final class SnackBar: UIView {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let stackView = UIStackView()

    public init() {
        super.init(frame: .zero)

        //alpha = 0.0
        backgroundColor = Asset.brandPrimary.color

        imageView.contentMode = .center
        titleLabel.text = Localized.Shared.SnackBar.title
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 13.0)
        titleLabel.textColor = Asset.neutralWhite.color
        imageView.image = Asset.sharedWhiteExclamation.image

        stackView.spacing = 14
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)

        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    required init?(coder: NSCoder) { nil }
}
