import UIKit
import Shared
import AppResources

final class AudioView: UIView {
    // MARK: UI

    let timeLabel = UILabel()
    let stackView = UIStackView()
    let spectrumView = UIImageView()
    let leftButton = UIButton()
    let rightButton = UIButton()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        layer.cornerRadius = 4
        backgroundColor = Asset.brandDefault.color

        timeLabel.textColor = Asset.neutralWhite.color
        timeLabel.font = Fonts.Mulish.semiBold.font(size: 10.0)
        leftButton.setImage(Asset.chatAudioPlay.image, for: .normal)
        rightButton.setImage(Asset.chatAudioCloseSpeaker.image, for: .normal)
        spectrumView.image = Asset.chatAudioSpectrum.image

        stackView.addArrangedSubview(leftButton)
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(spectrumView)
        stackView.addArrangedSubview(rightButton)

        stackView.setCustomSpacing(3, after: leftButton)
        stackView.setCustomSpacing(13, after: timeLabel)
        stackView.setCustomSpacing(13, after: spectrumView)

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}
