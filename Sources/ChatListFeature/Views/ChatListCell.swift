import UIKit
import Shared

final class ChatListCell: UITableViewCell {
    let titleLabel = UILabel()
    let unreadView = UIView()
    let previewLabel = UILabel()
    let dateLabel = UILabel()
    let avatarView = AvatarView()
    let coloringView = UIView()

    private var timer: Timer?

    var date: Date? {
        didSet {
            updateTimeAgoLabel()
        }
    }

    deinit {
        timer?.invalidate()
    }

    var didLongPress: EmptyClosure?
    private let longPressGesture = UILongPressGestureRecognizer(target: nil, action: nil)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        longPressGesture.addTarget(self, action: #selector(longAction))
        addGestureRecognizer(longPressGesture)

        backgroundColor = .clear
        selectedBackgroundView = UIView()
        multipleSelectionBackgroundView = UIView()

        timer = Timer.scheduledTimer(withTimeInterval: 59, repeats: true) { [weak self] _ in
            self?.updateTimeAgoLabel()
        }

        previewLabel.numberOfLines = 2
        unreadView.layer.cornerRadius = 8
        avatarView.layer.cornerRadius = 21
        dateLabel.textAlignment = .right
        avatarView.layer.masksToBounds = true

        dateLabel.setContentHuggingPriority(.init(rawValue: 251), for: .vertical)
        dateLabel.setContentHuggingPriority(.init(rawValue: 251), for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.init(rawValue: 751), for: .vertical)
        dateLabel.setContentCompressionResistancePriority(.init(rawValue: 751), for: .horizontal)

        unreadView.backgroundColor = .clear
        backgroundColor = Asset.neutralWhite.color
        titleLabel.textColor = Asset.neutralActive.color
        previewLabel.textColor = Asset.neutralDisabled.color
        dateLabel.textColor = Asset.neutralWeak.color

        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
        previewLabel.font = Fonts.Mulish.regular.font(size: 12.0)
        dateLabel.font = Fonts.Mulish.regular.font(size: 10.0)

        insertSubview(coloringView, belowSubview: contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(unreadView)
        contentView.addSubview(avatarView)
        contentView.addSubview(previewLabel)
        contentView.addSubview(dateLabel)

        coloringView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-6)
        }

        avatarView.snp.makeConstraints {
            $0.top.equalTo(coloringView).offset(6)
            $0.left.equalToSuperview().offset(28)
            $0.width.height.equalTo(48)
            $0.bottom.equalTo(coloringView).offset(-6)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(coloringView).offset(4)
            $0.left.equalTo(avatarView.snp.right).offset(16)
            $0.right.lessThanOrEqualTo(dateLabel.snp.left).offset(-10)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.right.equalToSuperview().offset(-24)
        }

        previewLabel.snp.makeConstraints {
            $0.left.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.right.lessThanOrEqualTo(unreadView.snp.left).offset(-3)
        }

        unreadView.snp.makeConstraints {
            $0.right.equalTo(dateLabel)
            $0.centerY.equalTo(previewLabel)
            $0.width.height.equalTo(20)
        }
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        date = nil
        titleLabel.text = nil
        previewLabel.text = nil
        avatarView.prepareForReuse()
    }

    override func willTransition(to state: UITableViewCell.StateMask) {
        super.willTransition(to: state)

        UIView.transition(with: coloringView, duration: 0.4, options: .transitionCrossDissolve) {
            let isEditing = state == .showingEditControl
            self.coloringView.backgroundColor = isEditing ?
                Asset.neutralSecondary.color : Asset.neutralWhite.color
        }

        UIView.transition(with: dateLabel, duration: 0.4, options: .transitionCrossDissolve) {
            let isEditing = state == .showingEditControl
            self.dateLabel.alpha = isEditing ? 0.0 : 1.0
        }

        UIView.transition(with: avatarView, duration: 0.1, options: .transitionCrossDissolve) {
            let isEditing = state == .showingEditControl

            self.avatarView.snp.updateConstraints {
                $0.left.equalToSuperview().offset(isEditing ? 16 : 28)
            }
        }
    }

    private func updateTimeAgoLabel() {
        guard let date = date else { return }
        dateLabel.text = date.asRelativeFromNow()
    }

    @objc private func longAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            didLongPress?()
        }
    }
}
