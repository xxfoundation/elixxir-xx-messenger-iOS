import UIKit
import Combine
import Defaults
import Integration
import DependencyInjection

struct ScanDisplayViewState: Equatable {
    var image: CIImage?
    var isSharingEmail: Bool = false
    var isSharingPhone: Bool = false
}

final class ScanDisplayViewModel {
    // MARK: Stored

    @KeyObject(.email, defaultValue: nil) var email: String?
    @KeyObject(.phone, defaultValue: nil) var phone: String?
    @KeyObject(.sharingEmail, defaultValue: false) var sharingEmail: Bool
    @KeyObject(.sharingPhone, defaultValue: false) var sharingPhone: Bool

    // MARK: Properties

    var state: AnyPublisher<ScanDisplayViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<ScanDisplayViewState, Never>(.init())

    // MARK: Injected

    @Dependency private var session: SessionType

    // MARK: Public

    func loadCached() {
        stateRelay.value.isSharingEmail = sharingEmail
        stateRelay.value.isSharingPhone = sharingPhone
    }

    func didToggleEmail() {
        sharingEmail.toggle()
        generateQR()
    }

    func didTogglePhone() {
        sharingPhone.toggle()
        generateQR()
    }

    func generateQR() {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return }

        filter.setValue(session.myQR, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 5, y: 5)

        if let output = filter.outputImage?.transformed(by: transform) {
            stateRelay.value.image = output
        }
    }
}
