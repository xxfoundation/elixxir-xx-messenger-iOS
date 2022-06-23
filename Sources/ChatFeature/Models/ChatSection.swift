import Foundation
import DifferenceKit

struct ChatSection: Equatable, Differentiable {
    var date: Date
    var differenceIdentifier: Date { date }
}
