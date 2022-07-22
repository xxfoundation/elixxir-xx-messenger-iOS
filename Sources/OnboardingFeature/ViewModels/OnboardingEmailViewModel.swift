import HUD
import UIKit
import Models
import Shared
import Combine
import Defaults
import InputField
import Integration
import CombineSchedulers
import DependencyInjection

struct OnboardingEmailViewState: Equatable {
    var input: String = ""
    var confirmation: AttributeConfirmation? = nil
    var status: InputField.ValidationStatus = .unknown(nil)
}

final class OnboardingEmailViewModel {
    @KeyObject(.pushNotifications, defaultValue: false) private var pushNotifications

    @Dependency private var session: SessionType

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var state: AnyPublisher<OnboardingEmailViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<OnboardingEmailViewState, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    func clearUp() {
        stateRelay.value.confirmation = nil
    }

    func didInput(_ string: String) {
        stateRelay.value.input = string
        validate()
    }

    func didTapNext() {
        hudRelay.send(.on)

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            self.session.register(.email, value: self.stateRelay.value.input) { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .success(let confirmationId):
                    self.hudRelay.send(.none)
                    self.stateRelay.value.confirmation =
                        .init(content: self.stateRelay.value.input, isEmail: true, confirmationId: confirmationId)
                case .failure(let error):
                    self.hudRelay.send(.error(.init(with: error)))
                }
            }
        }
    }

    private func validate() {
        switch Validator.email.validate(stateRelay.value.input) {
        case .success:
            stateRelay.value.status = .valid(nil)
        case .failure(let error):
            stateRelay.value.status = .invalid(error)
        }
    }
}
