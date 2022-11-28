import UIKit
import Shared
import AppResources

typealias IncomingReplyCell = CollectionCell<ReplyStackMessageView, FlexibleSpace>
typealias OutgoingReplyCell = CollectionCell<FlexibleSpace, ReplyStackMessageView>
typealias OutgoingFailedReplyCell = CollectionCell<FlexibleSpace, ReplyStackMessageView>

final class ReplyStackMessageView: UIView, CollectionCellContent {
    private let stackView = UIStackView()
    private let shapeLayer = CAShapeLayer()
    private let bottomStack = UIStackView()

    private(set) var dateLabel = UILabel()
    private(set) var textView = TextView()
    private(set) var replyView = ReplyView()
    private(set) var senderLabel = UILabel()
    private(set) var roundButton = UIButton()
    private(set) var lockerImageView = UIImageView()

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
        replyView.cleanUp()
        senderLabel.text = nil
        textView.resignFirstResponder()
        didTapShowRound = nil
    }

    func revertBottomStackOrder() {
        dateLabel.removeFromSuperview()
        bottomStack.insertArrangedSubview(dateLabel, at: 1)
    }

    private func setup() {
        lockerImageView.contentMode = .center
        lockerImageView.image = Asset.chatLocker.image

        let attrString = NSAttributedString(
            string: "show mix",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: Asset.neutralWhite.color,
                .foregroundColor: Asset.neutralWhite.color,
                .font: Fonts.Mulish.regular.font(size: 12.0) as Any
            ]
        )

        roundButton.addTarget(
            self,
            action: #selector(didTapRoundButton),
            for: .touchUpInside
        )

        roundButton.setAttributedTitle(attrString, for: .normal)
        dateLabel.font = Fonts.Mulish.regular.font(size: 12.0)
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 11, right: 0)
        senderLabel.textColor = Asset.brandDefault.color
        senderLabel.font = Fonts.Mulish.semiBold.font(size: 10.0)
        bottomStack.spacing = 10

        let roundButtonContainer = UIView()
        roundButtonContainer.addSubview(roundButton)
        roundButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }

        roundButtonContainer.setContentCompressionResistancePriority(.required, for: .horizontal)

        bottomStack.addArrangedSubview(roundButtonContainer)
        bottomStack.addArrangedSubview(dateLabel)
        bottomStack.addArrangedSubview(lockerImageView)

        bottomStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        stackView.axis = .vertical
        stackView.addArrangedSubview(senderLabel)
        stackView.addArrangedSubview(replyView)
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(bottomStack)
        stackView.setCustomSpacing(4, after: textView)
        stackView.setCustomSpacing(5, after: senderLabel)

        addSubview(stackView)
        setupConstraints()
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 10).isActive = true
        stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
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
