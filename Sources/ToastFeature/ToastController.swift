import Combine

public final class ToastController {
    private let queue = CurrentValueSubject<[ToastModel], Never>([])

    var currentToast: AnyPublisher<ToastModel, Never> {
        queue.compactMap(\.first)
            .removeDuplicates(by: { $0.id == $1.id })
            .eraseToAnyPublisher()
    }

    public init() {}

    public func enqueueToast(model: ToastModel) {
        queue.value.append(model)
    }

    public func dismissCurrentToast() {
        guard queue.value.isEmpty == false else { return }
        _ = queue.value.removeFirst()
    }
}
