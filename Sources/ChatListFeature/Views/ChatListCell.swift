import UIKit
import Shared

final class ChatListCell: UITableViewCell {
    // MARK: UI

    let title = UILabel()
    let unread = UIView()
    let preview = UILabel()
    let dateLabel = UILabel()
    let avatar = AvatarView()
    let coloringView = UIView()

    // MARK: Properties

    private var timer: Timer?

    var date: Date? {
        didSet { updateTimeAgoLabel() }
    }

    deinit { timer?.invalidate() }

    var didLongPress: EmptyClosure?
    private let longPressGesture = UILongPressGestureRecognizer(target: nil, action: nil)

    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        longPressGesture.addTarget(self, action: #selector(longAction))
        addGestureRecognizer(longPressGesture)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()

        date = nil
        title.text = nil
        preview.text = nil
        avatar.prepareForReuse()
    }

    override func willTransition(to state: UITableViewCell.StateMask) {
        super.willTransition(to: state)

        UIView.transition(with: self.coloringView, duration: 0.4, options: .transitionCrossDissolve) {
            let isEditing = state == .showingEditControl
            self.coloringView.backgroundColor = isEditing ?
                Asset.neutralSecondary.color : Asset.neutralWhite.color
        }

        UIView.transition(with: self.dateLabel, duration: 0.4, options: .transitionCrossDissolve) {
            let isEditing = state == .showingEditControl
            self.dateLabel.alpha = isEditing ? 0.0 : 1.0
        }

        UIView.transition(with: self.avatar, duration: 0.1, options: .transitionCrossDissolve) {
            let isEditing = state == .showingEditControl

            self.avatar.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(isEditing ? 16 : 28)
            }
        }
    }

    // MARK: Public

    func setup(
        title: String,
        photo: Data?
    ) {
        self.title.text = title
        self.avatar.set(
            cornerRadius: 16,
            username: title,
            image: photo
        )
    }

    // MARK: Private

    private func setup() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        multipleSelectionBackgroundView = UIView()

        timer = Timer.scheduledTimer(withTimeInterval: 59, repeats: true) { [weak self] _ in
            self?.updateTimeAgoLabel()
        }

        preview.numberOfLines = 2
        unread.layer.cornerRadius = 8
        avatar.layer.cornerRadius = 21
        dateLabel.textAlignment = .right
        avatar.layer.masksToBounds = true

        dateLabel.setContentHuggingPriority(.init(rawValue: 251), for: .vertical)
        dateLabel.setContentHuggingPriority(.init(rawValue: 251), for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.init(rawValue: 751), for: .vertical)
        dateLabel.setContentCompressionResistancePriority(.init(rawValue: 751), for: .horizontal)

        unread.backgroundColor = .clear
        backgroundColor = Asset.neutralWhite.color
        title.textColor = Asset.neutralActive.color
        preview.textColor = Asset.neutralDisabled.color
        dateLabel.textColor = Asset.neutralWeak.color

        title.font = Fonts.Mulish.semiBold.font(size: 14.0)
        preview.font = Fonts.Mulish.regular.font(size: 12.0)
        dateLabel.font = Fonts.Mulish.regular.font(size: 10.0)

        insertSubview(coloringView, belowSubview: contentView)
        contentView.addSubview(title)
        contentView.addSubview(unread)
        contentView.addSubview(avatar)
        contentView.addSubview(preview)
        contentView.addSubview(dateLabel)

        setupConstraints()
    }

    private func updateTimeAgoLabel() {
        guard let date = date else { return }
        dateLabel.text = date.asRelativeFromNow()
    }

    private func setupConstraints() {
        coloringView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
        }

        avatar.snp.makeConstraints { make in
            make.top.equalTo(coloringView).offset(6)
            make.left.equalToSuperview().offset(28)
            make.width.height.equalTo(48)
            make.bottom.equalTo(coloringView).offset(-6)
        }

        title.snp.makeConstraints { make in
            make.top.equalTo(coloringView).offset(4)
            make.left.equalTo(avatar.snp.right).offset(16)
            make.right.lessThanOrEqualTo(dateLabel.snp.left).offset(-10)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(title)
            make.right.equalToSuperview().offset(-24)
        }

        preview.snp.makeConstraints { make in
            make.left.equalTo(title)
            make.top.equalTo(title.snp.bottom).offset(3)
            make.right.lessThanOrEqualTo(unread.snp.left).offset(-3)
        }

        unread.snp.makeConstraints { make in
            make.right.equalTo(dateLabel)
            make.centerY.equalTo(preview)
            make.width.height.equalTo(20)
        }
    }

    // MARK: Selectors

    @objc private func longAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            didLongPress?()
        }
    }
}
