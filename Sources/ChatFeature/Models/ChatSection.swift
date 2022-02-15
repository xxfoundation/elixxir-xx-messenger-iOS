import Foundation
import DifferenceKit

struct ChatSection: Equatable, Differentiable {
    // MARK: Properties

    var date: Date

    // MARK: DifferenceKit

    var differenceIdentifier: Date { date }
}
