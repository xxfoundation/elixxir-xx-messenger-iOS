import UIKit

public final class PopupEmptyView: PopupStackItem {
    private var height: CGFloat

    public init(height: CGFloat) {
        self.height = height
    }

    public func makeView() -> UIView {
        let view = UIView()
        view.snp.makeConstraints { $0.height.equalTo(height) }

        return view
    }
}
