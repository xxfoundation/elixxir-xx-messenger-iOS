import UIKit
import Shared

final class SectionHeaderView: UICollectionReusableView {
    // MARK: UI

    let left = UIView()
    let title = UILabel()
    let right = UIView()

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        title.font = Fonts.Mulish.regular.font(size: 12.0)
        title.textColor = Asset.neutralDisabled.color
        title.textAlignment = .center
        backgroundColor = .clear

        left.backgroundColor = Asset.neutralLine.color
        right.backgroundColor = Asset.neutralLine.color

        addSubview(left)
        addSubview(title)
        addSubview(right)

        left.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(title)
            make.right.equalTo(title.snp.left).offset(-16)
            make.height.equalTo(1)
        }

        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().offset(-13)
            make.center.equalToSuperview()
        }

        right.snp.makeConstraints { make in
            make.left.equalTo(title.snp.right).offset(16)
            make.centerY.equalTo(title)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1)
        }
    }
}
