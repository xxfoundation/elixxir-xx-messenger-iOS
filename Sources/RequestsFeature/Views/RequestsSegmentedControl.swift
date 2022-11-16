import UIKit
import Shared
import SnapKit

final class RequestsSegmentedControl: UIView {
  private let trackView = UIView()
  private let stackView = UIStackView()
  private var leftConstraint: Constraint?
  private let trackIndicatorView = UIView()
  private(set) var sentRequestsButton = RequestSegmentedButton()
  private(set) var failedRequestsButton = RequestSegmentedButton()
  private(set) var receivedRequestsButton = RequestSegmentedButton()
  
  init() {
    super.init(frame: .zero)
    trackView.backgroundColor = Asset.neutralLine.color
    trackIndicatorView.backgroundColor = Asset.brandPrimary.color
    
    sentRequestsButton.titleLabel.text = Localized.Requests.Sent.title
    failedRequestsButton.titleLabel.text = Localized.Requests.Failed.title
    receivedRequestsButton.titleLabel.text = Localized.Requests.Received.title
    
    sentRequestsButton.titleLabel.textColor = Asset.neutralDisabled.color
    failedRequestsButton.titleLabel.textColor = Asset.neutralDisabled.color
    receivedRequestsButton.titleLabel.textColor = Asset.brandPrimary.color
    
    sentRequestsButton.imageView.tintColor = Asset.neutralDisabled.color
    failedRequestsButton.imageView.tintColor = Asset.neutralDisabled.color
    receivedRequestsButton.imageView.tintColor = Asset.brandPrimary.color
    
    sentRequestsButton.imageView.image = Asset.requestsTabSent.image
    failedRequestsButton.imageView.image = Asset.requestsTabFailed.image
    receivedRequestsButton.imageView.image = Asset.requestsTabReceived.image
    
    stackView.addArrangedSubview(receivedRequestsButton)
    stackView.addArrangedSubview(sentRequestsButton)
    stackView.addArrangedSubview(failedRequestsButton)
    stackView.distribution = .fillEqually
    stackView.backgroundColor = Asset.neutralWhite.color
    
    addSubview(stackView)
    addSubview(trackView)
    trackView.addSubview(trackIndicatorView)
    
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    trackView.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.height.equalTo(2)
    }
    
    trackIndicatorView.snp.makeConstraints {
      $0.top.equalToSuperview()
      leftConstraint = $0.left.equalToSuperview().constraint
      $0.width.equalToSuperview().dividedBy(3)
      $0.bottom.equalToSuperview()
    }
    
    sentRequestsButton.accessibilityIdentifier = Localized.Accessibility.Requests.Sent.tab
    failedRequestsButton.accessibilityIdentifier = Localized.Accessibility.Requests.Failed.tab
    receivedRequestsButton.accessibilityIdentifier = Localized.Accessibility.Requests.Received.tab
  }
  
  required init?(coder: NSCoder) { nil }
  
  func updateSwipePercentage(_ percentageScrolled: CGFloat) {
    let amountOfTabs = 3.0
    let tabWidth = bounds.width / amountOfTabs
    let leftOffset = percentageScrolled * tabWidth
    
    leftConstraint?.update(offset: leftOffset)
    
    let receivedPercentage = percentageScrolled > 1 ? 1 : percentageScrolled
    let failedPercentage = percentageScrolled <= 1 ? 0 : percentageScrolled - 1
    let sentPercentage = percentageScrolled > 1 ? 1 - (percentageScrolled-1) : percentageScrolled
    
    let sentColor = UIColor.fade(from: Asset.neutralDisabled.color, to: Asset.brandPrimary.color, pcent: sentPercentage)
    let failedColor = UIColor.fade(from: Asset.neutralDisabled.color, to: Asset.brandPrimary.color, pcent: failedPercentage)
    let receivedColor = UIColor.fade(from: Asset.brandPrimary.color, to: Asset.neutralDisabled.color, pcent: receivedPercentage)
    
    sentRequestsButton.imageView.tintColor = sentColor
    sentRequestsButton.titleLabel.textColor = sentColor
    
    failedRequestsButton.imageView.tintColor = failedColor
    failedRequestsButton.titleLabel.textColor = failedColor
    
    receivedRequestsButton.imageView.tintColor = receivedColor
    receivedRequestsButton.titleLabel.textColor = receivedColor
  }
}
