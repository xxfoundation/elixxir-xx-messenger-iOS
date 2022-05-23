import UIKit
import Shared

final class RequestSegmentedButton: UIControl {
    let titleLabel = UILabel()
    let imageView = UIImageView()

    init() {
        super.init(frame: .zero)

        titleLabel.textAlignment = .center
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        addSubview(titleLabel)
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7.5)
            $0.centerX.equalTo(titleLabel)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-7.5)
        }
    }

    required init?(coder: NSCoder) { nil }
}
