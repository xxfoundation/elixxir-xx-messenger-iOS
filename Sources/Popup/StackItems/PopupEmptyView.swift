import UIKit

public final class PopupEmptyView: PopupStackItem {
    // MARK: Lifecycle

    public init() {}

    // MARK: Builder

    public func makeView() -> UIView { UIView() }
}
