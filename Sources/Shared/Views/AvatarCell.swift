import UIKit
import Combine

public final class AvatarCell: UICollectionViewCell {
    public struct Action {
        public var title: String
        public var color: UIColor
        public var image: UIImage?
        public var action: () -> Void

        public init(
            title: String,
            color: UIColor,
            image: UIImage? = nil,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.color = color
            self.image = image
            self.action = action
        }
    }

    private let h1Label = UILabel()
    private let h2Label = UILabel()
    private let h3Label = UILabel()
    private let h4Label = UILabel()
    private let separatorView = UIView()
    private let avatarView = AvatarView()
    private let stackView = UIStackView()
    private var didTapAction: (() -> Void)?
    private let actionButton = AvatarCellButton()
    private var cancellables = Set<AnyCancellable>()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Asset.neutralWhite.color
        separatorView.backgroundColor = Asset.neutralLine.color

        h1Label.textColor = Asset.neutralActive.color
        h2Label.textColor = Asset.neutralSecondaryAlternative.color
        h3Label.textColor = Asset.neutralSecondaryAlternative.color
        h4Label.textColor = Asset.neutralSecondaryAlternative.color

        h1Label.font = Fonts.Mulish.semiBold.font(size: 14.0)
        h2Label.font = Fonts.Mulish.regular.font(size: 14.0)
        h3Label.font = Fonts.Mulish.regular.font(size: 14.0)
        h4Label.font = Fonts.Mulish.regular.font(size: 14.0)

        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.addArrangedSubview(h1Label)
        stackView.addArrangedSubview(h2Label)
        stackView.addArrangedSubview(h3Label)
        stackView.addArrangedSubview(h4Label)

        contentView.addSubview(stackView)
        contentView.addSubview(avatarView)
        contentView.addSubview(actionButton)
        contentView.addSubview(separatorView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    public override func prepareForReuse() {
        super.prepareForReuse()
        h1Label.text = nil
        h2Label.text = nil
        h3Label.text = nil
        h4Label.text = nil
        didTapAction = nil

        avatarView.prepareForReuse()
        actionButton.prepareForReuse()

        cancellables.removeAll()
    }

    public func set(
        image: Data?,
        h1Text: String,
        h2Text: String? = nil,
        h3Text: String? = nil,
        h4Text: String? = nil,
        showSeparator: Bool = true,
        action: Action? = nil
    ) {
        avatarView.setupProfile(
            title: h1Text,
            image: image,
            size: .medium
        )

        h1Label.text = h1Text
        h2Label.text = h2Text
        h3Label.text = h3Text
        h4Label.text = h4Text

        h2Label.isHidden = h2Text == nil
        h3Label.isHidden = h3Text == nil
        h4Label.isHidden = h4Text == nil

        separatorView.isHidden = !showSeparator

        if let action = action {
            update(action: action)
        }
    }

    public func update(action: Action) {
        cancellables.removeAll()

        actionButton.set(
            image: action.image,
            title: action.title,
            titleColor: action.color
        )

        didTapAction = action.action

        actionButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapAction?() }
            .store(in: &cancellables)
    }

    private func setupConstraints() {
        avatarView.snp.makeConstraints {
            $0.width.height.equalTo(36)
            $0.left.equalToSuperview().offset(27)
            $0.centerY.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(avatarView)
            $0.left.equalTo(avatarView.snp.right).offset(14)
            $0.right.lessThanOrEqualToSuperview().offset(-10)
            $0.bottom.greaterThanOrEqualTo(avatarView)
            $0.bottom.lessThanOrEqualToSuperview()
        }

        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(25)
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        actionButton.snp.makeConstraints {
            $0.centerY.equalTo(stackView)
            $0.right.equalToSuperview().offset(-24)
        }
    }
}
