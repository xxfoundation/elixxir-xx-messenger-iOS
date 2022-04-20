import HUD
import Shared
import Combine
import InputField
import Integration
import CombineSchedulers
import DependencyInjection

struct OnboardingUsernameViewState: Equatable {
    var input: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
}

final class OnboardingUsernameViewModel {

    let ndf: String

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    var greenPublisher: AnyPublisher<Void, Never> { greenRelay.eraseToAnyPublisher() }
    private let greenRelay = PassthroughSubject<Void, Never>()

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var state: AnyPublisher<OnboardingUsernameViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<OnboardingUsernameViewState, Never>(.init())

    init(ndf: String) {
        self.ndf = ndf
    }

    func didInput(_ string: String) {
        stateRelay.value.input = string.trimmingCharacters(in: .whitespacesAndNewlines)

        switch Validator.username.validate(stateRelay.value.input) {
        case .success(let text):
            stateRelay.value.status = .valid(text)
        case .failure(let error):
            stateRelay.value.status = .invalid(error)
        }
    }

    func didTapRegister() {
        hudRelay.send(.on(nil))

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                var session: SessionType!

                if let injectedSession = try? DependencyInjection.Container.shared.resolve() as SessionType {
                    session = injectedSession
                } else {
                    session = try Session(ndf: self.ndf)
                    DependencyInjection.Container.shared.register(session as SessionType)
                }

                session.register(.username, value: self.stateRelay.value.input) { [weak self] in
                    guard let self = self else { return }

                    switch $0 {
                    case .success(_):
                        self.hudRelay.send(.none)
                        self.greenRelay.send()
                    case .failure(let error):
                        self.hudRelay.send(.none)
                        self.stateRelay.value.status = .invalid(error.localizedDescription)
                    }
                }
            } catch {
                self.hudRelay.send(.none)
                self.stateRelay.value.status = .invalid(error.localizedDescription)
            }
        }
    }
}
