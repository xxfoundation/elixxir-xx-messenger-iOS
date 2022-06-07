import UIKit
import Combine
import Defaults
import Countries
import Integration
import DependencyInjection

struct ScanDisplayViewState: Equatable {
    var image: CIImage?
    var email: String?
    var phone: String?
    var isSharingEmail: Bool = false
    var isSharingPhone: Bool = false
}

final class ScanDisplayViewModel {
    @Dependency private var session: SessionType

    @KeyObject(.email, defaultValue: nil) private var email: String?
    @KeyObject(.phone, defaultValue: nil) private var phone: String?
    @KeyObject(.sharingEmail, defaultValue: false) private var sharingEmail: Bool
    @KeyObject(.sharingPhone, defaultValue: false) private var sharingPhone: Bool

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

        filter.setValue(session.myQR, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 5, y: 5)

        if let output = filter.outputImage?.transformed(by: transform) {
            stateSubject.value.image = output
        }
    }
}
