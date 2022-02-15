import HUD
import Shared
import Models
import Combine
import Countries
import InputField
import Integration
import CombineSchedulers
import DependencyInjection

struct OnboardingPhoneViewState: Equatable {
    var input: String = ""
    var confirmation: AttributeConfirmation?
    var status: InputField.ValidationStatus = .unknown(nil)
    var country: Country = .fromMyPhone()
}

final class OnboardingPhoneViewModel {
    @Dependency private var session: SessionType

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var state: AnyPublisher<OnboardingPhoneViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<OnboardingPhoneViewState, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    // MARK: Public

    func clearUp() {
        stateRelay.value.confirmation = nil
    }

    func didInput(_ string: String) {
        stateRelay.value.input = string
        validate()
    }

    func didChooseCountry(_ country: Country) {
        stateRelay.value.country = country
        validate()
    }

    func didGoForward() {
        stateRelay.value.confirmation = nil
    }

    func didTapNext() {
        hudRelay.send(.on)

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            let content = "\(self.stateRelay.value.input)\(self.stateRelay.value.country.code)"
            self.session.register(.phone, value: content) { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .success(let confirmationId):
                    self.hudRelay.send(.none)
                    self.stateRelay.value.confirmation = .init(
                        content: content,
                        confirmationId: confirmationId
                    )
                case .failure(let error):
                    self.hudRelay.send(.error(.init(with: error)))
                }
            }
        }
    }

    private func validate() {
        switch Validator.phone.validate((stateRelay.value.country.regex, stateRelay.value.input)) {
        case .success:
            stateRelay.value.status = .valid(nil)
        case .failure(let error):
            stateRelay.value.status = .invalid(error)
        }
    }
}
