import UIKit
import Shared

typealias IncomingTextCell = CollectionCell<StackMessageView, FlexibleSpace>
typealias OutgoingTextCell = CollectionCell<FlexibleSpace, StackMessageView>
typealias OutgoingFailedTextCell = CollectionCell<FlexibleSpace, StackMessageView>

final class StackMessageView: UIView, CollectionCellContent {
    let roundButton = UIButton()
    let dateLabel = UILabel()
    let textView = TextView()
    let lockerView = LockerView()
    let senderLabel = UILabel()
    private let stackView = UIStackView()
    private let shapeLayer = CAShapeLayer()
    private let bottomStack = UIStackView()

    var didTapShowRound: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }

    required init?(coder: NSCoder) { nil }

    func prepareForReuse() {
        dateLabel.text = nil
        textView.text = nil
        senderLabel.text = nil
        textView.resignFirstResponder()
        lockerView.icon.layer.removeAllAnimations()
        didTapShowRound = nil
    }

    func revertBottomStackOrder() {
        dateLabel.removeFromSuperview()
        bottomStack.insertArrangedSubview(dateLabel, at: 1)
    }

    private func setup() {
        roundButton.addTarget(
            self,
            action: #selector(didTapRoundButton),
            for: .touchUpInside
        )

        let attrString = NSAttributedString(
            string: "show mix",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: Asset.neutralWhite.color,
                .foregroundColor: Asset.neutralWhite.color,
                .font: Fonts.Mulish.regular.font(size: 12.0) as Any
            ]
        )

        roundButton.setAttributedTitle(attrString, for: .normal)
        senderLabel.textColor = Asset.brandDefault.color
        senderLabel.font = Fonts.Mulish.semiBold.font(size: 10.0)
        dateLabel.font = Fonts.Mulish.regular.font(size: 12.0)
        layoutMargins = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)

        bottomStack.spacing = 3
        bottomStack.addArrangedSubview(FlexibleSpace())
        bottomStack.addArrangedSubview(roundButton)
        bottomStack.addArrangedSubview(dateLabel)
        bottomStack.addArrangedSubview(lockerView)

        stackView.spacing = 6
        stackView.axis = .vertical
        stackView.addArrangedSubview(senderLabel)
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(bottomStack)

        addSubview(stackView)
        setupConstraints()
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 5).isActive = true
        stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -3).isActive = true
        stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
    }

    private func updatePath() {
        UIView.performWithoutAnimation {
            shapeLayer.frame = bounds
            shapeLayer.path = UIBezierPath(bounds.size, rad: 13).cgPath
            layer.mask = shapeLayer
        }
    }

    @objc private func didTapRoundButton() {
        didTapShowRound?()
    }
}
