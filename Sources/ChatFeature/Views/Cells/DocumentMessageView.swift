import UIKit
import Shared

typealias OutgoingDocumentCell = CollectionCell<FlexibleSpace, DocumentMessageView>
typealias IncomingDocumentCell = CollectionCell<DocumentMessageView, FlexibleSpace>

final class DocumentMessageView: UIView, CollectionCellContent {
    // MARK: UI

    let titleLabel = UILabel()
    let imageView = UIImageView()

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    func prepareForReuse() {
        imageView.image = nil
        titleLabel.text = nil
    }

    // MARK: Private

    private func setup() {
        layer.borderWidth = 2
        layer.borderColor = Asset.accentWarning.color.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        titleLabel.textColor = Asset.neutralDark.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 15.0)

        addSubview(imageView)
        imageView.addSubview(titleLabel)

        insetsLayoutMarginsFromSafeArea = false
        translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -15).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 15).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -15).isActive = true
    }
}
