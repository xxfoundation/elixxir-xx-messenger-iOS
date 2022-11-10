import UIKit
import Navigation
import DependencyInjection

public struct PresentPhotoLibrary: Navigation.Action {
  public var animated: Bool

  public init(animated: Bool = true) {
    self.animated = animated
  }
}

public struct PresentPhotoLibraryNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: () -> UIImagePickerController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentPhotoLibrary, completion: @escaping () -> Void) {
    if let topViewController = navigationController().topViewController {
      let imagePicker = screen()
      imagePicker.delegate = topViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
      let modalAction = PresentModal(imagePicker, from: topViewController)
      navigator.perform(modalAction, completion: completion)
    }
  }

  public init(
    screen: @escaping () -> UIImagePickerController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
