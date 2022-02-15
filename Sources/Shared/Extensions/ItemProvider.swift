import UIKit
import Combine

public extension NSItemProvider {
    func loadImageObjectPublisher() -> AnyPublisher<UIImage, Error> {
        Deferred {
            Future { promise in
                self.loadObject(ofClass: UIImage.self) { image, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let safeImage = image as? UIImage else {
                        struct InvalidImageError: Error {
                            let image: NSItemProviderReading?
                        }

                        promise(.failure(InvalidImageError(image: image)))
                        return
                    }

                    promise(.success(safeImage))
                }
            }
        }.eraseToAnyPublisher()
    }
}
