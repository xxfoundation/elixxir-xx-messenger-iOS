import XCTest

@testable import Presentation

final class SideMenuPresenterTests: XCTestCase {
    var sut: SideMenuPresenter!
    private var dismissInteractor: MockSideMenuDismissalInteractor!
    private var menuAnimator: MockSideMenuAnimator!

    override func setUp() {
        dismissInteractor = MockSideMenuDismissalInteractor()
        menuAnimator = MockSideMenuAnimator()

        sut = SideMenuPresenter(
            dismissInteractor: dismissInteractor,
            menuAnimator: menuAnimator,
            viewAnimator: MockUIViewAnimator.self
        )
    }

    override func tearDown() {
        sut = nil
        dismissInteractor = nil
        menuAnimator = nil
    }

    func test_animationControllerForPresenting() {
        let animationController = sut.animationController(forPresented: UIViewController(),
                                                          presenting: UIViewController(),
                                                          source: UIViewController())

        let sideMenuPresentTransition = animationController as? SideMenuPresentTransition

        XCTAssertNotNil(sideMenuPresentTransition)
        XCTAssert((sideMenuPresentTransition?.dismissInteractor as? MockSideMenuDismissalInteractor) === dismissInteractor)
        XCTAssert((sideMenuPresentTransition?.menuAnimator as? MockSideMenuAnimator) === menuAnimator)
        XCTAssertTrue(sideMenuPresentTransition?.viewAnimator is MockUIViewAnimator.Type)
    }

    func test_animationControllerForDismissing() {
        let animationController = sut.animationController(forDismissed: UIViewController())
        let sideMenuDismissTransition = animationController as? SideMenuDismissTransition

        XCTAssertNotNil(sideMenuDismissTransition)
        XCTAssert((sideMenuDismissTransition?.menuAnimator as? MockSideMenuAnimator) === menuAnimator)
        XCTAssertTrue(sideMenuDismissTransition?.viewAnimator is MockUIViewAnimator.Type)
    }

    func test_InteractionForDismissalWhenInteractionIsInProgress() {
        let animatedTransitioning = MockViewControllerAnimatedTransitioning()
        dismissInteractor.interactionInProgress = true
        let controller = sut.interactionControllerForDismissal(using: animatedTransitioning)

        XCTAssertNotNil(controller)
    }

    func test_InteractionForDismissalWhenInteractionIsNotInProgress() {
        let animatedTransitioning = MockViewControllerAnimatedTransitioning()
        dismissInteractor.interactionInProgress = false
        let controller = sut.interactionControllerForDismissal(using: animatedTransitioning)

        XCTAssertNil(controller)
    }
}

private final class MockViewControllerAnimatedTransitioning: NSObject,
                                                             UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        fatalError()
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError()
    }
}

private final class MockSideMenuDismissalInteractor: NSObject, SideMenuDismissInteracting {
    var interactionInProgress: Bool = true
    var percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()

    func setup(view: UIView, action: @escaping () -> Void) {
        fatalError()
    }

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        fatalError()
    }
}

private final class MockSideMenuAnimator: SideMenuAnimating {
    func animate(in containerView: UIView, to progress: CGFloat) {
        fatalError()
    }
}

private final class MockUIViewAnimator: Presentation.UIViewAnimating {
    static func animate(withDuration duration: TimeInterval,
                        animations: @escaping () -> Void,
                        completion: ((Bool) -> Void)?) {
        fatalError()
    }
}
