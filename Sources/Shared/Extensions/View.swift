import UIKit
import SnapKit

protocol ReusableView {}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public extension UIView {
    enum PinningPosition {
        case hCenter
        case top(CGFloat)
        case left(CGFloat)
        case right(CGFloat)
        case bottom(CGFloat)
        case center(CGFloat)
    }

    func pinning(at position: PinningPosition) -> UIView {
        let container = UIView()
        container.addSubview(self)

        self.snp.makeConstraints { make in
            switch position {
            case let .top(padding):
                let flex = FlexibleSpace()
                container.addSubview(flex)
                flex.snp.makeConstraints { $0.bottom.equalToSuperview() }

                make.top.equalToSuperview().offset(padding)
                make.left.right.equalToSuperview()
                make.bottom.lessThanOrEqualTo(flex.snp.top)

            case let .left(padding):
                let flex = FlexibleSpace()
                container.addSubview(flex)
                flex.snp.makeConstraints { $0.right.equalToSuperview() }

                make.top.bottom.equalToSuperview()
                make.left.equalToSuperview().offset(padding)
                make.right.lessThanOrEqualTo(flex.snp.left)

            case let .right(padding):
                let flex = FlexibleSpace()
                container.addSubview(flex)
                flex.snp.makeConstraints { $0.bottom.equalToSuperview() }

                make.top.bottom.equalToSuperview()
                make.right.equalToSuperview().offset(padding)
                make.left.greaterThanOrEqualTo(flex.snp.right)

            case let .bottom(padding):
                let flex = FlexibleSpace()
                container.addSubview(flex)
                flex.snp.makeConstraints { $0.top.equalToSuperview() }

                make.bottom.equalToSuperview().offset(padding)
                make.left.right.equalToSuperview()
                make.top.greaterThanOrEqualTo(flex.snp.bottom)

            case let .center(inset):
                make.top.greaterThanOrEqualToSuperview().offset(inset)
                make.left.greaterThanOrEqualToSuperview().offset(inset)
                make.center.equalToSuperview()
                make.right.lessThanOrEqualToSuperview().offset(-inset)
                make.bottom.lessThanOrEqualToSuperview().offset(-inset)
            case .hCenter:
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualToSuperview()
                make.right.lessThanOrEqualToSuperview()
                make.bottom.equalToSuperview()
            }
        }

        return container
    }
}
