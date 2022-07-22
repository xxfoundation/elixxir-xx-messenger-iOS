import HUD
import Models
import Shared
import Combine
import InputField
import Integration
import CombineSchedulers
import DependencyInjection

struct ProfileEmailViewState: Equatable {
    var input: String = ""
    var confirmation: AttributeConfirmation? = nil
    var status: InputField.ValidationStatus = .unknown(nil)
}

final class ProfileEmailViewModel {
    // MARK: Injected

    @Dependency private var session: SessionType

    // MARK: Properties

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var state: AnyPublisher<ProfileEmailViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<ProfileEmailViewState, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    // MARK: Public

    func didInput(_ string: String) {
        stateRelay.value.input = string
        validate()
    }

    func clearUp() {
        stateRelay.value.confirmation = nil
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
                    self.stateRelay.value.confirmation = .init(
                        content: self.stateRelay.value.input,
                        isEmail: true,
                        confirmationId: confirmationId
                    )
                case .failure(let error):
                    self.hudRelay.send(.error(.init(with: error)))
                }
            }
        }
    }

    // MARK: Private

    private func validate() {
        switch Validator.email.validate(stateRelay.value.input) {
        case .success:
            stateRelay.value.status = .valid(nil)
        case .failure(let error):
            stateRelay.value.status = .invalid(error)
        }
    }
}
