import UIKit
import Shared

protocol CollectionCellContent: UIView {
    func prepareForReuse()
}

final class CollectionCell<LeftView: CollectionCellContent, RightView: CollectionCellContent>:
    UICollectionViewCell, UIGestureRecognizerDelegate {

    // MARK: Properties

    var canReply = false
    var performReply: () -> Void = {}
    let leftView = LeftView(frame: .zero)
    let rightView = RightView(frame: .zero)

    private let container = UIView()
    private var shouldTriggerReply: Bool = false
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gesture.delegate = self
        return gesture
    }()

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        leftView.prepareForReuse()
        rightView.prepareForReuse()
        shouldTriggerReply = false
        container.transform = .identity

        canReply = false
        performReply = {}
    }

    // MARK: Private

    private func setup() {
        contentView.addSubview(container)
        container.addSubview(leftView)
        container.addSubview(rightView)
        container.addGestureRecognizer(panGesture)

        container.snp.makeConstraints { $0.edges.equalToSuperview() }

        leftView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        rightView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalTo(leftView.snp.right)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: ObjC

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translationX = gesture.translation(in: self).x
        let triggerX = self.frame.size.width / 5
        let progress = translationX / triggerX

        if progress < 1.0 {
            container.transform = .init(translationX: translationX, y: 0)
        } else {
            container.transform = .init(translationX: triggerX + ((translationX - triggerX) * 0.2), y: 0)
        }

        shouldTriggerReply = progress >= 1

        switch gesture.state {
        case .ended, .cancelled, .failed:
            if shouldTriggerReply {
                performReply()
                shouldTriggerReply = false
            }

            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                self.container.transform = .identity
            }
        default:
            break
        }
    }

    // MARK: UIGestureRecognizerDelegate

    override public func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
        guard gesture == panGesture else { return true }
        guard canReply else { return false }

        let translation = panGesture.translation(in: self)
        return abs(translation.x) > abs(translation.y)
    }
}
