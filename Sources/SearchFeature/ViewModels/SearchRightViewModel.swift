import Permissions
import DependencyInjection

enum SearchQRStatus: Equatable {
    case reading
    case processing
    case success
    case failed(SearchQRError)
}

enum SearchQRError: Equatable {
    case requestOpened
    case unknown(String)
    case cameraPermission
    case alreadyFriends(String)
}

final class SearchRightViewModel {
    @Dependency private var permissions: PermissionHandling
}

//
//
//import Combine
//import AVFoundation
//
//protocol CameraType {
//    func start()
//    func stop()
//
//    var previewLayer: CALayer { get }
//    var dataPublisher: AnyPublisher<Data, Never> { get }
//}
//
//final class Camera: NSObject, CameraType {
//    var dataPublisher: AnyPublisher<Data, Never> {
//        dataSubject
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//
//    lazy var previewLayer: CALayer = {
//        let layer = AVCaptureVideoPreviewLayer(session: session)
//        layer.videoGravity = .resizeAspectFill
//        return layer
//    }()
//
//    private let session = AVCaptureSession()
//    private let metadataOutput = AVCaptureMetadataOutput()
//    private let dataSubject = PassthroughSubject<Data, Never>()
//
//    override init() {
//        super.init()
//        setupCameraDevice()
//    }
//
//    func start() {
//        guard session.isRunning == false else { return }
//        session.startRunning()
//    }
//
//    func stop() {
//        guard session.isRunning == true else { return }
//        session.stopRunning()
//    }
//
//    private func setupCameraDevice() {
//        if let captureDevice = AVCaptureDevice.default(for: .video),
//           let input = try? AVCaptureDeviceInput(device: captureDevice) {
//
//            if session.canAddInput(input) && session.canAddOutput(metadataOutput) {
//                session.addInput(input)
//                session.addOutput(metadataOutput)
//            }
//
//            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
//            metadataOutput.metadataObjectTypes = [.qr]
//        }
//    }
//}
//
//extension Camera: AVCaptureMetadataOutputObjectsDelegate {
//    func metadataOutput(
//        _ output: AVCaptureMetadataOutput,
//        didOutput metadataObjects: [AVMetadataObject],
//        from connection: AVCaptureConnection
//    ) {
//        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
//              let data = object.stringValue?.data(using: .nonLossyASCII), object.type == .qr else { return }
//        dataSubject.send(data)
//    }
//}
//
//final class MockCamera: NSObject, CameraType {
//    private let dataSubject = PassthroughSubject<Data, Never>()
//
//    func start() {
//        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
//            self?.dataSubject.send("###".data(using: .utf8)!)
//        }
//    }
//
//    func stop() {}
//
//    var previewLayer: CALayer { CALayer() }
//
//    var dataPublisher: AnyPublisher<Data, Never> {
//        dataSubject
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//}
