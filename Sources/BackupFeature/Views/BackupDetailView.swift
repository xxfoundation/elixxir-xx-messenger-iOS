import UIKit
import Shared
import AppResources

final class BackupDetailView: UIControl {
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  let accessoryImageView = UIImageView()

  init() {
    super.init(frame: .zero)

    titleLabel.font = Fonts.Mulish.bold.font(size: 12.0)
    subtitleLabel.font = Fonts.Mulish.regular.font(size: 16.0)

    titleLabel.textColor = Asset.neutralWeak.color
    subtitleLabel.textColor = Asset.neutralActive.color

    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(accessoryImageView)

    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.left.equalToSuperview().offset(92)
    }

    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
      make.left.equalTo(titleLabel)
      make.bottom.equalToSuperview().offset(-2)
    }

    accessoryImageView.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-48)
      make.centerY.equalTo(titleLabel.snp.bottom)
    }
  }

  required init?(coder: NSCoder) { nil }
}
