import UIKit
import Shared
import Combine

final class ToastView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let leftImageView = UIImageView()
    private let rightButton = UIButton()
    private let verticalStackView = UIStackView()
    private let horizontalStackView = UIStackView()
    private var cancellables = Set<AnyCancellable>()

    init(model: ToastModel) {
        super.init(frame: .zero)
        backgroundColor = model.color
        layer.cornerRadius = 18.0

        titleLabel.textColor = .white
        subtitleLabel.textColor = .white
        leftImageView.contentMode = .center

        titleLabel.numberOfLines = 0
        subtitleLabel.numberOfLines = 0
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 16.0)
        subtitleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        leftImageView.image = Asset.sharedSuccess.image
        leftImageView.setContentHuggingPriority(.required, for: .horizontal)

        rightButton.titleLabel?.numberOfLines = 0
        rightButton.titleLabel?.textAlignment = .center
        rightButton.titleLabel?.font = Fonts.Mulish.bold.font(size: 12.0)

        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subtitleLabel)

        horizontalStackView.spacing = 12
        horizontalStackView.addArrangedSubview(leftImageView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        horizontalStackView.addArrangedSubview(rightButton)

        addSubview(horizontalStackView)

        horizontalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-17)
        }

        titleLabel.text = model.title
        leftImageView.image = model.leftImage

        if let subtitle = model.subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.numberOfLines = 0
        } else {
            subtitleLabel.isHidden = true
        }

        if let buttonTitle = model.buttonTitle {
            rightButton.setTitle(buttonTitle, for: .normal)
            rightButton.setContentHuggingPriority(.required, for: .horizontal)
        } else {
            rightButton.isHidden = true
        }

        rightButton
            .publisher(for: .touchUpInside)
            .sink { model.onTapClosure?() }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) { nil }
}
