import UIKit
import Shared

final class ScanOverlayView: UIView {
    let cropView = UIView()
    let maskLayer = CAShapeLayer()

    let topLeftLayer = CAShapeLayer()
    let topRightLayer = CAShapeLayer()
    let bottomLeftLayer = CAShapeLayer()
    let bottomRightLayer = CAShapeLayer()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralDark.color.withAlphaComponent(0.5)

        addSubview(cropView)

        cropView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(207)
        }

        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer
        layer.masksToBounds = true

        [topLeftLayer, topRightLayer, bottomLeftLayer, bottomRightLayer].forEach {
            $0.strokeColor = Asset.brandPrimary.color.cgColor
            $0.fillColor = UIColor.clear.cgColor
            $0.lineWidth = 3.0
            $0.lineCap = .round
            layer.addSublayer($0)
        }
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()

        maskLayer.frame = bounds
        let path = UIBezierPath(rect: bounds)
        path.append(UIBezierPath(roundedRect: cropView.frame, cornerRadius: 30.0))
        maskLayer.path = path.cgPath

        topLeftLayer.frame = bounds
        topRightLayer.frame = bounds
        bottomRightLayer.frame = bounds
        bottomLeftLayer.frame = bounds

        topLeftLayer.path = topLeftPath()
        topRightLayer.path = topRightPath()
        bottomRightLayer.path = bottomRightPath()
        bottomLeftLayer.path = bottomLeftPath()
    }

    func updateCornerColor(_ color: UIColor) {
        [topLeftLayer, topRightLayer, bottomLeftLayer, bottomRightLayer].forEach {
            $0.strokeColor = color.cgColor
        }
    }

    func topLeftPath() -> CGPath {
        let path = UIBezierPath()
        path.addArc(
            center: CGPoint(x: cropView.frame.minX + 10, y: cropView.frame.minY + 10),
            startAngle: .pi
        )
        return path.cgPath
    }

    func topRightPath() -> CGPath {
        let path = UIBezierPath()
        path.addArc(
            center: CGPoint(x: cropView.frame.maxX - 10, y: cropView.frame.minY + 10),
            startAngle: 3 * .pi/2
        )
        return path.cgPath
    }

    func bottomRightPath() -> CGPath {
        let path = UIBezierPath()
        path.addArc(
            center: CGPoint(x: cropView.frame.maxX - 10, y: cropView.frame.maxY - 10),
            startAngle: 0
        )

        return path.cgPath
    }

    func bottomLeftPath() -> CGPath {
        let path = UIBezierPath()
        path.addArc(
            center: CGPoint(x: cropView.frame.minX + 10, y: cropView.frame.maxY - 10),
            startAngle: .pi/2
        )
        return path.cgPath
    }
}

private extension UIBezierPath {
    func addArc(center: CGPoint, startAngle: CGFloat) {
        addArc(
            withCenter: center,
            radius: 30,
            startAngle: startAngle,
            endAngle: startAngle + .pi/2,
            clockwise: true
        )
    }
}
