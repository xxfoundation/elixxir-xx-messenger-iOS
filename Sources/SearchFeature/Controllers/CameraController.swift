import Combine
import AVFoundation

final class CameraController: NSObject {
    var dataPublisher: AnyPublisher<Data, Never> {
        dataSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    lazy var previewLayer: CALayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()

    private let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    private let dataSubject = PassthroughSubject<Data, Never>()

    override init() {
        super.init()
        setupCameraDevice()
    }

    func start() {
        guard session.isRunning == false else { return }
        session.startRunning()
    }

    func stop() {
        guard session.isRunning == true else { return }
        session.stopRunning()
    }

    private func setupCameraDevice() {
        if let captureDevice = AVCaptureDevice.default(for: .video),
           let input = try? AVCaptureDeviceInput(device: captureDevice) {

            if session.canAddInput(input) && session.canAddOutput(metadataOutput) {
                session.addInput(input)
                session.addOutput(metadataOutput)
            }

            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let data = object.stringValue?.data(using: .nonLossyASCII), object.type == .qr else { return }
        dataSubject.send(data)
    }
}

extension CameraController: AVCaptureMetadataOutputObjectsDelegate {}
