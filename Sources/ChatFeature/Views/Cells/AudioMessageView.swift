import UIKit
import Shared
import Combine

typealias OutgoingAudioCell = CollectionCell<FlexibleSpace, AudioMessageView>
typealias IncomingAudioCell = CollectionCell<AudioMessageView, FlexibleSpace>

struct AudioMessageCellState {
    var date: Date
    var audioURL: URL
    var isPlaying: Bool
    var transferProgress: Float
    var isLoudspeaker: Bool
    var duration: TimeInterval
    var playbackTime: TimeInterval
}

final class AudioMessageView: UIView, CollectionCellContent {
    private let playerView = AudioView()
    private let stackView = UIStackView()
    private let shapeLayer = CAShapeLayer()
    private let bottomStack = UIStackView()

    private(set) var dateLabel = UILabel()
    private(set) var progressLabel = UILabel()
    private(set) var lockerImageView = UIImageView()

    var didTapLeft: (() -> Void)?
    var didTapRight: (() -> Void)?
    var cancellables = Set<AnyCancellable>()

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
        didTapLeft = nil
        didTapRight = nil
        dateLabel.text = nil
        progressLabel.text = nil
        playerView.timeLabel.text = nil
        cancellables.removeAll()
    }

    func setup(with model: AudioMessageCellState) {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad

        progressLabel.text = String(format: "%.1f%%", model.transferProgress * 100)

        playerView.timeLabel.text = model.isPlaying ?
        formatter.string(from: model.playbackTime) : formatter.string(from: model.duration)

        let isPlayingImage = Asset.chatAudioPause.image
        let isNotPlayingImage = Asset.chatAudioPlay.image

        playerView.leftButton.setImage(
            model.isPlaying ? isPlayingImage : isNotPlayingImage , for: .normal
        )

        let isLoudspeakerImage = Asset.chatAudioOpenSpeaker.image
        let isNotLoudspeakerImage = Asset.chatAudioCloseSpeaker.image

        playerView.rightButton.setImage(
            model.isLoudspeaker ? isLoudspeakerImage : isNotLoudspeakerImage , for: .normal
        )
    }

    private func setup() {
        lockerImageView.contentMode = .center
        lockerImageView.image = Asset.chatLocker.image

        dateLabel.textColor = Asset.neutralWhite.color
        dateLabel.font = Fonts.Mulish.regular.font(size: 12.0)
        progressLabel.textColor = Asset.neutralWhite.color
        progressLabel.font = Fonts.Mulish.regular.font(size: 12.0)

        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 11, right: 0)
        bottomStack.spacing = 10
        bottomStack.addArrangedSubview(progressLabel.pinning(at: .left(0)))
        bottomStack.addArrangedSubview(dateLabel.pinning(at: .right(0)))
        bottomStack.addArrangedSubview(lockerImageView)

        stackView.axis = .vertical
        stackView.addArrangedSubview(playerView)
        stackView.addArrangedSubview(bottomStack)
        addSubview(stackView)

        playerView.leftButton.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        playerView.rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)

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

    @objc private func didTapRightButton() {
        didTapRight?()
    }

    @objc private func didTapLeftButton() {
        didTapLeft?()
    }
}
