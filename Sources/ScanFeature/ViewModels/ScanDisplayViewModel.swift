import UIKit
import Models
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

        var facts: [Fact] = [Fact(fact: username!, type: FactType.username.rawValue)]

        if sharingPhone {
            facts.append(Fact(fact: phone!, type: FactType.phone.rawValue))
        }

        if sharingEmail {
            facts.append(Fact(fact: email!, type: FactType.email.rawValue))
        }

        let e2e = messenger.e2e.get()!
        let contactData = e2e.getContact().data
        let wrappedContact = try! SetFactsOnContact.live(contactData: contactData, facts: facts)

        filter.setValue(wrappedContact, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 5, y: 5)

        if let output = filter.outputImage?.transformed(by: transform) {
            stateSubject.value.image = output
        }
    }
}
