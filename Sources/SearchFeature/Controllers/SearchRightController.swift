import UIKit
import DependencyInjection

final class SearchRightController: UIViewController {
    lazy private var screenView = SearchRightView()

//    private let camera = Camera()
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
//        permissions.requestCamera { [weak self] granted in
//            guard let self = self else { return }
//
//            if granted {
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self else { return }
//                    self.camera.start()
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.status = .failed(.cameraPermission)
////                    self.screenView.update(with: .failed(.cameraPermission))
//                }
//            }
//        }
    }
}
