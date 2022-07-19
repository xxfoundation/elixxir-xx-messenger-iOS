import UIKit
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

final class SearchRightController: UIViewController {
    @Dependency private var permissions: PermissionHandling

    lazy private var screenView = SearchRightView()

    private let camera = Camera()
    private var status: SearchQRStatus?

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ///screenView.layer.insertSublayer(camera.previewLayer, at: 0)
        ///setupBindings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ///camera.previewLayer.frame = screenView.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ///viewModel.resetScanner()
        ///startCamera()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        backgroundScheduler.schedule { [weak self] in
//            guard let self = self else { return }
//            self.camera.stop()
//        }
    }

    private func startCamera() {
        permissions.requestCamera { [weak self] granted in
            guard let self = self else { return }

            if granted {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.camera.start()
                }
            } else {
                DispatchQueue.main.async {
                    self.status = .failed(.cameraPermission)
//                    self.screenView.update(with: .failed(.cameraPermission))
                }
            }
        }
    }
}


import Combine
import AVFoundation

protocol CameraType {
    func start()
    func stop()

    var previewLayer: CALayer { get }
    var dataPublisher: AnyPublisher<Data, Never> { get }
}

final class Camera: NSObject, CameraType {
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
}

extension Camera: AVCaptureMetadataOutputObjectsDelegate {
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

final class MockCamera: NSObject, CameraType {
    private let dataSubject = PassthroughSubject<Data, Never>()

    func start() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.dataSubject.send("###".data(using: .utf8)!)
        }
    }

    func stop() {}

    var previewLayer: CALayer { CALayer() }

    var dataPublisher: AnyPublisher<Data, Never> {
        dataSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
