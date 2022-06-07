import UIKit
import Shared

final class ChatSearchListContainerView: UIView{
    let emptyView = ChatSearchEmptyView()

    init() {
        super.init(frame: .zero)

        addSubview(emptyView)

        emptyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}

final class ChatListContainerView: UIView {
    let separatorView = UIView()
    let emptyView = ChatListEmptyView()
    let collectionContainerView = UIView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 35
        layout.itemSize = CGSize(width: 56, height: 80)
        layout.scrollDirection = .horizontal
        return layout
    }()

    init() {
        super.init(frame: .zero)

        collectionView.showsHorizontalScrollIndicator = false
        separatorView.backgroundColor = Asset.neutralLine.color
        collectionView.backgroundColor = Asset.neutralWhite.color
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)

        addSubview(emptyView)
        addSubview(collectionContainerView)
        collectionContainerView.addSubview(collectionView)
        collectionContainerView.addSubview(separatorView)

        collectionContainerView.snp.makeConstraints {
            $0.bottom.equalTo(snp.top)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(110)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }

        separatorView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(20)
            $0.height.equalTo(1)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints {
            $0.top.equalTo(collectionContainerView.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    func showRecentsCollection(_ show: Bool) {
        if show == true && collectionContainerView.alpha != 0.0 ||
            show == false && collectionContainerView.alpha == 0.0 {
            return
        }

        if show == true {
            collectionContainerView.alpha = 0.0
            collectionContainerView.snp.updateConstraints {
                $0.bottom.equalTo(snp.top).offset(collectionContainerView.bounds.height + 20)
            }

            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut) {
                self.collectionContainerView.alpha = 1.0
            }

            UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseInOut) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        } else {
            collectionContainerView.alpha = 1.0
            collectionContainerView.snp.updateConstraints {
                $0.bottom.equalTo(snp.top)
            }

            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut) {
                self.collectionContainerView.alpha = 0.0
            }

            UIView.animate(withDuration: 0.2, delay: 0.15, options: .curveEaseInOut) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
}
