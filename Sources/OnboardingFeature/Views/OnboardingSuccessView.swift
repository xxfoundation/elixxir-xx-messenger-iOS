import UIKit
import Shared
import AppResources

final class OnboardingSuccessView: UIView {
  let titleLabel = UILabel()
  let imageView = UIImageView()
  let nextButton = CapsuleButton()

  init() {
    super.init(frame: .zero)
    imageView.image = Asset.onboardingSuccess.image

    addSubview(imageView)
    addSubview(titleLabel)
    addSubview(nextButton)

    imageView.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide).offset(40)
      $0.left.equalToSuperview().offset(40)
    }
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(40)
      $0.left.equalToSuperview().offset(40)
      $0.right.equalToSuperview().offset(-90)
    }
    nextButton.snp.makeConstraints {
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
      $0.bottom.equalToSuperview().offset(-60)
    }
  }

  required init?(coder: NSCoder) { nil }
}
