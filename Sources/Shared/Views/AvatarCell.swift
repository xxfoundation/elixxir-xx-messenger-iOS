import UIKit

public final class AvatarCell: UITableViewCell {
    let h1Label = UILabel()
    let h2Label = UILabel()
    let h3Label = UILabel()
    let h4Label = UILabel()
    let separatorView = UIView()
    let avatarView = AvatarView()
    let stackView = UIStackView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectedBackgroundView = UIView()
        multipleSelectionBackgroundView = UIView()
        backgroundColor = Asset.neutralWhite.color

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

        separatorView.backgroundColor = Asset.neutralLine.color

        contentView.addSubview(stackView)
        contentView.addSubview(avatarView)
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

        avatarView.prepareForReuse()
    }

    public func setup(
        title: String,
        image: Data?,
        firstSubtitle: String? = nil,
        secondSubtitle: String? = nil,
        thirdSubtitle: String? = nil,
        showSeparator: Bool = true
    ) {
        h1Label.text = title

        if let firstSubtitle = firstSubtitle {
            h2Label.isHidden = false
            h2Label.text = firstSubtitle
        } else {
            h2Label.isHidden = true
        }

        if let secondSubtitle = secondSubtitle {
            h3Label.isHidden = false
            h3Label.text = secondSubtitle
        } else {
            h3Label.isHidden = true
        }

        if let thirdSubtitle = thirdSubtitle {
            h4Label.isHidden = false
            h4Label.text = thirdSubtitle
        } else {
            h4Label.isHidden = true
        }

        avatarView.setupProfile(title: title, image: image, size: .medium)
        separatorView.alpha = showSeparator ? 1.0 : 0.0
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
    }
}
