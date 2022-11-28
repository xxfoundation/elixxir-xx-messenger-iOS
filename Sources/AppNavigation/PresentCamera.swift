import UIKit

/// Presents `Camera` on provided parent view controller
public struct PresentCamera: Action {
  /// - Parameters:
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.parent = parent
    self.animated = animated
  }

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentCamera` action
public struct PresentCameraNavigator: TypedNavigator {
  public init() {}

  public func perform(_ action: PresentCamera, completion: @escaping () -> Void) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .camera
    imagePickerController.delegate = action.parent as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
    action.parent.present(
      imagePickerController,
      animated: action.animated,
      completion: completion
    )
  }
}
