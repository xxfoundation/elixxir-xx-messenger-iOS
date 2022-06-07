import UIKit
import Shared

final class LaunchView: UIView {
    private var imageView = UIImageView()

    init() {
        super.init(frame: .zero)
        imageView.image = Asset.splash.image
        imageView.contentMode = .scaleAspectFit
        backgroundColor = Asset.neutralWhite.color

        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview().offset(100)
        }
    }

    required init?(coder: NSCoder) { nil }

    func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 122/255, green: 235/255, blue: 239/255, alpha: 1).cgColor,
            UIColor(red: 56/255, green: 204/255, blue: 232/255, alpha: 1).cgColor,
            UIColor(red: 63/255, green: 186/255, blue: 253/255, alpha: 1).cgColor,
            UIColor(red: 98/255, green: 163/255, blue: 255/255, alpha: 1).cgColor
        ]

        gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        layer.insertSublayer(gradient, at: 0)
    }
}
