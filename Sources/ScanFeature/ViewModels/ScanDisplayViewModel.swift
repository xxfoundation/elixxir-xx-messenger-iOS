import UIKit
import Combine
import Defaults
import Countries
import XXClient
import DependencyInjection
import XXMessengerClient

struct ScanDisplayViewState: Equatable {
    var image: CIImage?
    var email: String?
    var phone: String?
    var isSharingEmail: Bool = false
    var isSharingPhone: Bool = false
}

final class ScanDisplayViewModel {
    @Dependency var messenger: Messenger

    @KeyObject(.email, defaultValue: nil) var email: String?
    @KeyObject(.phone, defaultValue: nil) var phone: String?
    @KeyObject(.username, defaultValue: nil) var username: String?
    @KeyObject(.sharingEmail, defaultValue: false) var sharingEmail: Bool
    @KeyObject(.sharingPhone, defaultValue: false) var sharingPhone: Bool

    var statePublisher: AnyPublisher<ScanDisplayViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private let stateSubject = CurrentValueSubject<ScanDisplayViewState, Never>(.init())

    func loadCached() {
        var cleanPhone: String?

        if let dirtyPhone = phone {
            cleanPhone = "\(Country.findFrom(dirtyPhone).prefix)\(dirtyPhone.dropLast(2))"
        }

        stateSubject.value = .init(
            image: stateSubject.value.image,
            email: email,
            phone: cleanPhone,
            isSharingEmail: sharingEmail,
            isSharingPhone: sharingPhone
        )
    }

    func didToggleEmail() {
        sharingEmail.toggle()
        stateSubject.value.isSharingEmail = sharingEmail
        generateQR()
    }

    func didTogglePhone() {
        sharingPhone.toggle()
        stateSubject.value.isSharingPhone = sharingPhone
        generateQR()
    }

    func generateQR() {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return }

        var facts: [Fact] = [.init(type: .username, value: username!)]

        if sharingPhone {
            facts.append(.init(type: .phone, value: phone!))
        }

        if sharingEmail {
            facts.append(.init(type: .email, value: email!))
        }

        let e2e = messenger.e2e.get()!
        var contact = e2e.getContact()
        try! contact.setFacts(facts)

        filter.setValue(contact.data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 5, y: 5)

        if let output = filter.outputImage?.transformed(by: transform) {
            stateSubject.value.image = output
        }
    }
}
