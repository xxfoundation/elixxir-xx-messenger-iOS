import UIKit

public final class DotAnimation: UIView {
  let leftDot = UIView()
  let rightDot = UIView()
  let middleDot = UIView()
  var displayLink: CADisplayLink?

  var leftInvert = false
  var rightInvert = false
  var middleInvert = false
  var leftValue: CGFloat = 20
  var rightValue: CGFloat = 70
  var middleValue: CGFloat = 45

  public init() {
    super.init(frame: .zero)
    leftDot.layer.cornerRadius = 7.5
    middleDot.layer.cornerRadius = 7.5
    rightDot.layer.cornerRadius = 7.5

    setColor()

    addSubview(leftDot)
    addSubview(middleDot)
    addSubview(rightDot)

    leftDot.snp.makeConstraints {
      $0.centerY.equalTo(middleDot)
      $0.right.equalTo(middleDot.snp.left).offset(-5)
      $0.width.height.equalTo(15)
    }

    middleDot.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalTo(15)
    }

    rightDot.snp.makeConstraints {
      $0.centerY.equalTo(middleDot)
      $0.left.equalTo(middleDot.snp.right).offset(5)
      $0.width.height.equalTo(15)
    }

    displayLink = CADisplayLink(target: self, selector: #selector(handleAnimations))
    displayLink!.add(to: RunLoop.main, forMode: .default)
  }

  required init?(coder: NSCoder) { nil }

  func setColor(_ color: UIColor = Asset.brandPrimary.color) {
    leftDot.backgroundColor = color
    middleDot.backgroundColor = color
    rightDot.backgroundColor = color
  }

  @objc private func handleAnimations() {
    let factor: CGFloat = 70

    leftInvert ? (leftValue -= 1) : (leftValue += 1)
    middleInvert ? (middleValue -= 1) : (middleValue += 1)
    rightInvert ? (rightValue -= 1) : (rightValue += 1)

    leftDot.layer.transform = CATransform3DMakeScale(leftValue/factor, leftValue/factor, 1)
    middleDot.layer.transform = CATransform3DMakeScale(middleValue/factor, middleValue/factor, 1)
    rightDot.layer.transform = CATransform3DMakeScale(rightValue/factor, rightValue/factor, 1)

    if leftValue > factor || leftValue < 10 { leftInvert.toggle() }
    if middleValue > factor || middleValue < 10 { middleInvert.toggle() }
    if rightValue > factor || rightValue < 10 { rightInvert.toggle() }
  }
}
