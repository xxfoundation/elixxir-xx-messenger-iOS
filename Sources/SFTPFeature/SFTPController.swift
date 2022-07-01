import UIKit

public final class SFTPController: UIViewController {
    lazy private var screenView = SFTPView()

    public override func loadView() {
        view = screenView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back])
        )
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
