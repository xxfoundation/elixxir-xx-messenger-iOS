import XCTest

@testable import Presentation

final class SideMenuDismissTransitionTests: XCTestCase {
    var sut: SideMenuDismissTransition!
    private var menuAnimator: MockSideMenuAnimator!

    override func setUp() {
        menuAnimator = MockSideMenuAnimator()

        sut = SideMenuDismissTransition(
            menuAnimator: menuAnimator,
            viewAnimator: MockUIViewAnimator.self
        )
    }

    override func tearDown() {
        sut = nil
        menuAnimator = nil
    }

    func test_transitionDuration() {
        XCTAssertEqual(sut.transitionDuration(using: nil), 0.25)
    }

    func test_animateTransition() {
        let context = MockViewControllerContextTransitioning()

        sut.animateTransition(using: context)

        XCTAssertTrue(sut.viewAnimator is MockUIViewAnimator.Type)
        XCTAssertEqual(menuAnimator.didAnimateToProgress, 0)
        XCTAssertEqual(menuAnimator.didAnimateInContainerView, context.containerView)

        context.mockCancelTransition = false
        XCTAssertEqual(context.didCompleteTransition, true)
    }
}

private final class MockSideMenuAnimator: SideMenuAnimating {
    var didAnimateInContainerView: UIView?
    var didAnimateToProgress: CGFloat?

    func animate(in containerView: UIView, to progress: CGFloat) {
        didAnimateInContainerView = containerView
        didAnimateToProgress = progress
    }
}

private final class MockUIViewAnimator: Presentation.UIViewAnimating {
    static var didAnimateWithDuration: TimeInterval?

    static func animate(withDuration duration: TimeInterval,
                        animations: @escaping () -> Void,
                        completion: ((Bool) -> Void)?) {
        didAnimateWithDuration = duration
        animations()
        completion?(true)
    }
}

private final class MockViewControllerContextTransitioning: NSObject,
                                                            UIViewControllerContextTransitioning {
    let mockContainerView = UIView()
    var mockCancelTransition: Bool = false

    var didCompleteTransition: Bool?
    var containerView: UIView { mockContainerView }
    var transitionWasCancelled: Bool { mockCancelTransition }

    func completeTransition(_ didComplete: Bool) {
        didCompleteTransition = didComplete
    }

    var mockViewControllerForKey = [UITransitionContextViewControllerKey: UIViewController]()

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        fatalError()
    }

    var isAnimated: Bool { fatalError() }
    var isInteractive: Bool { fatalError() }
    var targetTransform: CGAffineTransform { fatalError() }
    var presentationStyle: UIModalPresentationStyle { fatalError() }

    func cancelInteractiveTransition() {fatalError() }
    func pauseInteractiveTransition() { fatalError() }
    func finishInteractiveTransition() { fatalError() }
    func finalFrame(for vc: UIViewController) -> CGRect { fatalError() }
    func initialFrame(for vc: UIViewController) -> CGRect { fatalError() }
    func view(forKey key: UITransitionContextViewKey) -> UIView? { fatalError() }
    func updateInteractiveTransition(_ percentComplete: CGFloat) { fatalError() }
}
