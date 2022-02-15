import UIKit
import SnapKit

public final class DotAnimation: UIView {
    // MARK: UI

    let leftDot = UIView()
    let middleDot = UIView()
    let rightDot = UIView()

    // MARK: Properties

    var leftInvert = false
    var middleInvert = false
    var rightInvert = false

    var leftValue: CGFloat = 20
    var middleValue: CGFloat = 45
    var rightValue: CGFloat = 70

    var displayLink: CADisplayLink?

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Public

    func setColor(_ color: UIColor = Asset.brandPrimary.color) {
        leftDot.backgroundColor = color
        middleDot.backgroundColor = color
        rightDot.backgroundColor = color
    }

    // MARK: Private

    private func setup() {
        setupCornerRadius()
        setColor()
        addSubviews()
        setupConstraints()

        displayLink = CADisplayLink(target: self, selector: #selector(handleAnimations))
        displayLink!.add(to: RunLoop.main, forMode: .default)
    }

    private func setupCornerRadius() {
        leftDot.layer.cornerRadius = 4.5
        middleDot.layer.cornerRadius = 4.5
        rightDot.layer.cornerRadius = 4.5
    }

    private func addSubviews() {
        addSubview(leftDot)
        addSubview(middleDot)
        addSubview(rightDot)
    }

    private func setupConstraints() {
        leftDot.snp.makeConstraints { make in
            make.centerY.equalTo(middleDot)
            make.right.equalTo(middleDot.snp.left).offset(-2)
            make.width.height.equalTo(9)
        }

        middleDot.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(9)
        }

        rightDot.snp.makeConstraints { make in
            make.centerY.equalTo(middleDot)
            make.left.equalTo(middleDot.snp.right).offset(2)
            make.width.height.equalTo(9)
        }
    }

    // MARK: Selectors

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
