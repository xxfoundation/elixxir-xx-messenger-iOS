import UIKit
import Shared

final class RequestsContainerView: UIView {
  let scrollView = UIScrollView()
  let sentController = RequestsSentController()
  let failedController = RequestsFailedController()
  let receivedController = RequestsReceivedController()
  let segmentedControl = RequestsSegmentedControl()
  
  init() {
    super.init(frame: .zero)
    scrollView.bounces = false
    scrollView.isScrollEnabled = false
    backgroundColor = Asset.neutralWhite.color
    
    scrollView.addSubview(sentController.view)
    scrollView.addSubview(failedController.view)
    scrollView.addSubview(receivedController.view)
    addSubview(segmentedControl)
    addSubview(scrollView)
    
    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    segmentedControl.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide).offset(10)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.height.equalTo(60)
    }
    
    receivedController.view.snp.makeConstraints {
      $0.top.equalTo(segmentedControl.snp.bottom)
      $0.left.equalToSuperview()
      $0.right.equalTo(sentController.view.snp.left)
      $0.bottom.equalTo(self)
      $0.width.equalTo(self)
    }
    
    sentController.view.snp.makeConstraints {
      $0.top.equalTo(segmentedControl.snp.bottom)
      $0.right.equalTo(failedController.view.snp.left)
      $0.bottom.equalTo(self)
      $0.width.equalTo(self)
    }
    
    failedController.view.snp.makeConstraints {
      $0.top.equalTo(segmentedControl.snp.bottom)
      $0.right.equalToSuperview()
      $0.bottom.equalTo(self)
      $0.width.equalTo(self)
    }
  }
  
  required init?(coder: NSCoder) { nil }
}
