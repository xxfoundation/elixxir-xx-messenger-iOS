import UIKit
import Shared

final class RestoreDetailsView: UIView {
    let separatorView = UIView()
    let imageView = UIImageView()
    let titleLabel = UILabel()

    let stackView = UIStackView()
    let dateView = DetailRowButton()
    let sizeView = DetailRowButton()

    init() {
        super.init(frame: .zero)
        separatorView.backgroundColor = Asset.neutralLine.color

        titleLabel.font = Fonts.Mulish.semiBold.font(size: 16.0)
        titleLabel.textColor = Asset.neutralActive.color

        stackView.axis = .vertical
        stackView.spacing = 22
        stackView.addArrangedSubview(dateView)
        stackView.addArrangedSubview(sizeView)

        addSubview(separatorView)
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(stackView)

        separatorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.height.equalTo(1)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.left.equalToSuperview().offset(92)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-40)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
    }

    required init?(coder: NSCoder) { nil }
}
