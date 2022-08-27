import HUD
import Shared
import Models
import Combine
import Defaults
import XXClient
import Foundation
import InputField
import CombineSchedulers
import DependencyInjection
import XXMessengerClient

struct ProfileCodeViewState: Equatable {
    var input: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
    var resendDebouncer: Int = 0
}

final class ProfileCodeViewModel {
    @Dependency var messenger: Messenger

    @KeyObject(.email, defaultValue: nil) var email: String?
    @KeyObject(.phone, defaultValue: nil) var phone: String?

    let confirmation: AttributeConfirmation

    var timer: Timer?

    var completionPublisher: AnyPublisher<AttributeConfirmation, Never> { completionRelay.eraseToAnyPublisher() }
    private let completionRelay = PassthroughSubject<AttributeConfirmation, Never>()

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var state: AnyPublisher<ProfileCodeViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<ProfileCodeViewState, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    init(_ confirmation: AttributeConfirmation) {
        self.confirmation = confirmation
        didTapResend()
    }

    func didInput(_ string: String) {
        stateRelay.value.input = string
        validate()
    }

    func didTapResend() {
        guard stateRelay.value.resendDebouncer == 0 else { return }

        stateRelay.value.resendDebouncer = 60

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {  [weak self] in
            guard let self = self, self.stateRelay.value.resendDebouncer > 0 else {
                $0.invalidate()
                return
            }

            self.stateRelay.value.resendDebouncer -= 1
        }
    }

    func didTapNext() {
        hudRelay.send(.on)

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.messenger.ud.get()!.confirmFact(
                    confirmationId: self.confirmation.confirmationId!,
                    code: self.stateRelay.value.input
                )

                if self.confirmation.isEmail {
                    self.email = self.confirmation.content
                } else {
                    self.phone = self.confirmation.content
                }

                self.timer?.invalidate()
                self.hudRelay.send(.none)
                self.completionRelay.send(self.confirmation)
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    private func validate() {
        switch Validator.code.validate(stateRelay.value.input) {
        case .success:
            stateRelay.value.status = .valid(nil)
        case .failure(let error):
            stateRelay.value.status = .invalid(error)
        }
    }
}
