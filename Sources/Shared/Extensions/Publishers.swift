import UIKit
import Combine

public extension UIControl {
    func publisher(for event: Event) -> EventPublisher {
        EventPublisher(
            control: self,
            event: event
        )
    }

    struct EventPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        fileprivate var control: UIControl
        fileprivate var event: Event

        public func receive<S: Subscriber>(
            subscriber: S
        ) where S.Input == Output, S.Failure == Failure {
            let subscription = EventSubscription<S>()
            subscription.target = subscriber
            subscriber.receive(subscription: subscription)

            control.addTarget(subscription,
                action: #selector(subscription.trigger),
                for: event
            )
        }
    }
}

private extension UIControl {
    class EventSubscription<Target: Subscriber>: Subscription
        where Target.Input == Void {

        var target: Target?

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            target = nil
        }

        @objc func trigger() {
            _ = target?.receive(())
        }
    }
}

public extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        publisher(for: .editingChanged)
            .map { self.text ?? "" }
            .eraseToAnyPublisher()
    }

    var returnPublisher: AnyPublisher<Void, Never> {
        publisher(for: .editingDidEndOnExit)
            .eraseToAnyPublisher()
    }
}

public extension UITextView {
    var textPublisher: Publishers.TextFieldPublisher {
        Publishers.TextFieldPublisher(textField: self)
    }
}

public extension Publishers {
    struct TextFieldPublisher: Publisher {
        public typealias Output = String
        public typealias Failure = Never

        private let textField: UITextView

        init(textField: UITextView) { self.textField = textField }

        public func receive<S>(subscriber: S) where S : Subscriber, Publishers.TextFieldPublisher.Failure == S.Failure, Publishers.TextFieldPublisher.Output == S.Input {
            let subscription = TextFieldSubscription(subscriber: subscriber, textField: textField)
            subscriber.receive(subscription: subscription)
        }
    }

    class TextFieldSubscription<S: Subscriber>: NSObject, Subscription, UITextViewDelegate where S.Input == String, S.Failure == Never  {

        private var subscriber: S?
        private weak var textField: UITextView?

        init(subscriber: S, textField: UITextView) {
            super.init()
            self.subscriber = subscriber
            self.textField = textField
            subscribe()
        }

        public func request(_ demand: Subscribers.Demand) { }

        public func cancel() {
            subscriber = nil
            textField = nil
        }

        private func subscribe() {
            textField?.delegate = self
        }

        public func textViewDidChange(_ textView: UITextView) {
            _ = subscriber?.receive(textView.text)
        }
    }
}
