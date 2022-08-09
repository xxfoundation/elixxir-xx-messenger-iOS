import HUD
import Shared
import Models
import Combine
import Countries
import InputField
import XXClient
import CombineSchedulers
import DependencyInjection

struct ProfilePhoneViewState: Equatable {
    var input: String = ""
    var confirmation: AttributeConfirmation? = nil
    var status: InputField.ValidationStatus = .unknown(nil)
    var country: Country = .fromMyPhone()
}

final class ProfilePhoneViewModel {
    // MARK: Injected

    @Dependency var userDiscovery: UserDiscovery

    // MARK: Properties

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var state: AnyPublisher<ProfilePhoneViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<ProfilePhoneViewState, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    // MARK: Public

    func didInput(_ string: String) {
        stateRelay.value.input = string
        validate()
    }

    func clearUp() {
        stateRelay.value.confirmation = nil
    }

    func didChooseCountry(_ country: Country) {
        stateRelay.value.country = country
        validate()
    }

    func didTapNext() {
        hudRelay.send(.on)

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            let content = "\(self.stateRelay.value.input)\(self.stateRelay.value.country.code)"

            do {
                let confirmationId = try self.userDiscovery.sendRegisterFact(
                    .init(fact: content, type: FactType.phone.rawValue)
                )

                self.hudRelay.send(.none)
                self.stateRelay.value.confirmation = .init(
                    content: content,
                    confirmationId: confirmationId
                )

            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    // MARK: Private

    private func validate() {
        switch Validator.phone.validate((stateRelay.value.country.regex, stateRelay.value.input)) {
        case .success:
            stateRelay.value.status = .valid(nil)
        case .failure(let error):
            stateRelay.value.status = .invalid(error)
        }
    }
}
