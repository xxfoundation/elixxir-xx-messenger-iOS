import UIKit
import Shared

final class ContactListView: UIView {
    private let separatorView = UIView()
    private(set) var emptyView = ContactListEmptyView()
    private(set) var newGroupButton = ContactListActionButton()
    private(set) var requestsButton = ContactListActionButton()

    lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = Asset.neutralWhite.color
        config.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        return collectionView
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color
        separatorView.backgroundColor = Asset.neutralLine.color

        let requestsTitle = Localized.ContactList.requests
        let requestsImage = Asset.contactListRequests.image
        requestsButton.setup(title: requestsTitle, image: requestsImage)

        let newGroupTitle = Localized.ContactList.newGroup
        let newGroupImage = Asset.contactListNewGroup.image
        newGroupButton.setup(title: newGroupTitle, image: newGroupImage)

        addSubview(emptyView)
        addSubview(separatorView)
        addSubview(collectionView)
        addSubview(newGroupButton)
        addSubview(requestsButton)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        newGroupButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }

        separatorView.snp.makeConstraints {
            $0.top.equalTo(newGroupButton.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.height.equalTo(1)
        }

        requestsButton.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }

        emptyView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(requestsButton.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
