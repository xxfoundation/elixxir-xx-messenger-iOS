import HUD
import Shared
import Models
import Combine
import Defaults
import XXModels
import InputField
import Foundation
import XXMessengerClient
import CombineSchedulers
import DependencyInjection

struct OnboardingUsernameViewState: Equatable {
    var input: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
}

final class OnboardingUsernameViewModel {
    @Dependency var database: Database
    @Dependency var messenger: Messenger

    @KeyObject(.username, defaultValue: "") var username: String

    var backgroundScheduler: AnySchedulerOf<DispatchQueue>
    = DispatchQueue.global().eraseToAnyScheduler()

    var greenPublisher: AnyPublisher<Void, Never> { greenRelay.eraseToAnyPublisher() }
    private let greenRelay = PassthroughSubject<Void, Never>()

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var state: AnyPublisher<OnboardingUsernameViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<OnboardingUsernameViewState, Never>(.init())

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
        hudRelay.send(.on)

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.messenger.register(
                    username: self.stateRelay.value.input
                )

                try self.database.saveContact(.init(
                    id: self.messenger.e2e.get()!.getContact().getId(),
                    marshaled: self.messenger.e2e.get()!.getContact().data,
                    username: self.stateRelay.value.input,
                    email: nil,
                    phone: nil,
                    nickname: nil,
                    photo: nil,
                    authStatus: .friend,
                    isRecent: false,
                    isBlocked: false,
                    isBanned: false,
                    createdAt: Date()
                ))

                self.username = self.stateRelay.value.input
                self.hudRelay.send(.none)
                self.greenRelay.send()
            } catch {
                self.hudRelay.send(.none)
                self.stateRelay.value.status = .invalid(error.localizedDescription)
            }
        }
    }
}
