import UIKit
import Shared
import AppResources

final class RestoreProgressView: UIView {
  let progressBarFull = UIView()
  let progressBarFiller = UIView()
  let progressLabel = UILabel()
  let warningLabel = UILabel()
  let descriptiveProgressLabel = UILabel()

  init() {
    super.init(frame: .zero)
    warningLabel.textColor = Asset.neutralDisabled.color
    progressLabel.textColor = Asset.neutralDisabled.color
    descriptiveProgressLabel.textColor = Asset.neutralDisabled.color

    warningLabel.font = Fonts.Mulish.regular.font(size: 14.0)
    progressLabel.font = Fonts.Mulish.regular.font(size: 14.0)
    descriptiveProgressLabel.font = Fonts.Mulish.regular.font(size: 14.0)

    descriptiveProgressLabel.textAlignment = .center

    progressBarFull.backgroundColor = Asset.neutralLine.color
    progressBarFiller.backgroundColor = Asset.brandPrimary.color
    progressBarFull.layer.masksToBounds = true
    progressBarFull.layer.cornerRadius = 4

    warningLabel.numberOfLines = 0
    descriptiveProgressLabel.numberOfLines = 0
    warningLabel.text = "This may take up to 5 mins, please don’t close the app and don’t put in background and don’t close your phone screen"

    addSubview(progressBarFull)
    addSubview(progressLabel)
    addSubview(warningLabel)
    addSubview(descriptiveProgressLabel)
    progressBarFull.addSubview(progressBarFiller)

    descriptiveProgressLabel.snp.makeConstraints { make in
      make.top.greaterThanOrEqualToSuperview()
      make.left.equalToSuperview().offset(42)
      make.right.equalToSuperview().offset(-42)
      make.bottom.equalTo(progressBarFull.snp.top).offset(-15)
    }

    progressBarFull.snp.makeConstraints { make in
      make.top.greaterThanOrEqualToSuperview()
      make.left.equalToSuperview().offset(42)
      make.right.equalToSuperview().offset(-42)
      make.centerY.equalToSuperview()
      make.height.equalTo(8)
    }

    progressBarFiller.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
      make.width.equalTo(0)
      make.bottom.equalToSuperview()
    }

    progressLabel.snp.makeConstraints { make in
      make.top.equalTo(progressBarFull.snp.bottom).offset(15)
      make.left.equalToSuperview().offset(42)
      make.right.equalToSuperview().offset(-42)
    }

    warningLabel.snp.makeConstraints { make in
      make.top.equalTo(progressLabel.snp.bottom).offset(15)
      make.left.equalToSuperview().offset(42)
      make.right.equalToSuperview().offset(-42)
      make.bottom.lessThanOrEqualToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }

  func update(downloaded: Float, total: Float) {
    let totalkb = String(format: "%.1f kb", total/1000)
    let downloadedKb = String(format: "%.1f kb", downloaded/1000)
    let percent = String(format: "%.0f", downloaded/total * 100)

    progressLabel.text = "Downloaded \(downloadedKb) of \(totalkb) (\(percent)%)"

    progressBarFiller.snp.updateConstraints { make in
      make.width.equalTo(CGFloat(downloaded/total) * progressBarFull.frame.size.width)
    }
  }
}
