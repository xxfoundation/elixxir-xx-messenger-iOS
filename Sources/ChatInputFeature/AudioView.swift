import UIKit
import Shared
import AppResources

final class AudioView: UIView {
  let stack = UIStackView()
  let timeLabel = UILabel()
  let playButton = UIButton()
  let sendButton = UIButton()
  let cancelButton = UIButton()
  let stopPlaybackButton = UIButton()
  let stopRecordingButton = UIButton()

  init() {
    super.init(frame: .zero)

    timeLabel.textAlignment = .center
    timeLabel.textColor = Asset.neutralDark.color
    timeLabel.font = Fonts.Mulish.semiBold.font(size: 13)

    sendButton.setImage(Asset.chatSend.image, for: .normal)
    playButton.setImage(Asset.chatInputVoicePlay.image, for: .normal)
    cancelButton.setImage(Asset.chatInputActionClose.image, for: .normal)
    stopPlaybackButton.setImage(Asset.chatInputVoicePause.image, for: .normal)
    stopRecordingButton.setImage(Asset.chatInputVoiceStop.image, for: .normal)

    stack.spacing = 8
    stack.axis = .horizontal
    stack.addArrangedSubview(cancelButton)
    stack.addArrangedSubview(playButton)
    stack.addArrangedSubview(stopPlaybackButton)
    stack.addArrangedSubview(timeLabel)
    stack.addArrangedSubview(stopRecordingButton)
    stack.addArrangedSubview(sendButton)

    cancelButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    playButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    stopPlaybackButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    sendButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

    addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) { nil }
}
