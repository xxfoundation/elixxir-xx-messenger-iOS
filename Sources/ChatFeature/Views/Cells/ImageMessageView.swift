import UIKit
import Shared
import AppResources

typealias OutgoingImageCell = CollectionCell<FlexibleSpace, ImageMessageView>
typealias IncomingImageCell = CollectionCell<ImageMessageView, FlexibleSpace>

final class ImageMessageView: UIView, CollectionCellContent {
    private let stackView = UIStackView()
    private let shapeLayer = CAShapeLayer()
    private let bottomStack = UIStackView()

    private(set) var dateLabel = UILabel()
    private(set) var progressLabel = UILabel()
    private(set) var imageView = UIImageView()
    private(set) var lockerImageView = UIImageView()

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
        imageView.image = nil
        dateLabel.text = nil
        progressLabel.text = nil
    }

    private func setup() {
        lockerImageView.contentMode = .center
        lockerImageView.image = Asset.chatLocker.image

        imageView.layer.cornerRadius = 10

        dateLabel.font = Fonts.Mulish.regular.font(size: 12.0)
        progressLabel.font = Fonts.Mulish.regular.font(size: 12.0)

        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 11, right: 0)
        bottomStack.spacing = 10
        bottomStack.addArrangedSubview(progressLabel.pinning(at: .left(0)))
        bottomStack.addArrangedSubview(dateLabel.pinning(at: .right(0)))
        bottomStack.addArrangedSubview(lockerImageView)

        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(bottomStack)
        addSubview(stackView)

        insetsLayoutMarginsFromSafeArea = false
        translatesAutoresizingMaskIntoConstraints = false

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 10).isActive = true
        stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
        stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }

    private func updatePath() {
        UIView.performWithoutAnimation {
            shapeLayer.frame = bounds
            shapeLayer.path = UIBezierPath(bounds.size, rad: 13).cgPath
            layer.mask = shapeLayer
        }
    }
}
