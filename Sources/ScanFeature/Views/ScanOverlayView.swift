import UIKit
import Shared
import AppResources

final class ScanOverlayView: UIView {
  private let cropView = UIView()
  private let scanViewLength = 266.0
  private let maskLayer = CAShapeLayer()
  private let topLeftLayer = CAShapeLayer()
  private let topRightLayer = CAShapeLayer()
  private let bottomLeftLayer = CAShapeLayer()
  private let bottomRightLayer = CAShapeLayer()

  init() {
    super.init(frame: .zero)
    backgroundColor = Asset.neutralDark.color.withAlphaComponent(0.5)

    addSubview(cropView)

    cropView.snp.makeConstraints {
      $0.width.equalTo(scanViewLength)
      $0.centerY.equalToSuperview().offset(-50)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(scanViewLength)
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

    let vert0X = cropView.frame.minX - 15
    let vert0Y = cropView.frame.minY + 45
    let vert0 = CGPoint(x: vert0X, y: vert0Y)
    path.move(to: vert0)

    let vertNX = cropView.frame.minX - 15
    let vertNY = cropView.frame.minY + 15
    let vertN = CGPoint(x: vertNX, y: vertNY)
    path.addLine(to: vertN)

    let arcCenterX = cropView.frame.minX + 15
    let arcCenterY = cropView.frame.minY + 15
    let arcCenter = CGPoint(x: arcCenterX , y: arcCenterY)
    path.addArc(center: arcCenter, startAngle: .pi)

    let horizX = cropView.frame.minX + 45
    let horizY = cropView.frame.minY - 15
    let horiz = CGPoint(x: horizX, y: horizY)
    path.addLine(to: horiz)

    return path.cgPath
  }

  func topRightPath() -> CGPath {
    let path = UIBezierPath()

    let horiz0X = cropView.frame.maxX - 45
    let horiz0Y = cropView.frame.minY - 15
    let horiz0 = CGPoint(x: horiz0X, y: horiz0Y)
    path.move(to: horiz0)

    let horizNX = cropView.frame.maxX - 15
    let horizNY = cropView.frame.minY - 15
    let horizN = CGPoint(x: horizNX, y: horizNY)
    path.addLine(to: horizN)

    let arcCenterX = cropView.frame.maxX - 15
    let arcCenterY = cropView.frame.minY + 15
    let arcCenter = CGPoint(x: arcCenterX, y: arcCenterY)
    path.addArc(center: arcCenter, startAngle: 3 * .pi/2)

    let vertX = cropView.frame.maxX + 15
    let vertY = cropView.frame.minY + 45
    let vert = CGPoint(x: vertX, y: vertY)
    path.addLine(to: vert)

    return path.cgPath
  }

  func bottomRightPath() -> CGPath {
    let path = UIBezierPath()

    let vert0X = cropView.frame.maxX + 15
    let vert0Y = cropView.frame.maxY - 45
    let vert0 = CGPoint(x: vert0X, y: vert0Y)
    path.move(to: vert0)

    let vertNX = cropView.frame.maxX + 15
    let vertNY = cropView.frame.maxY - 15
    let vertN = CGPoint(x: vertNX, y: vertNY)
    path.addLine(to: vertN)

    let arcCenterX = cropView.frame.maxX - 15
    let arcCenterY = cropView.frame.maxY - 15
    let arcCenter = CGPoint(x: arcCenterX, y: arcCenterY)
    path.addArc(center: arcCenter, startAngle: 0)

    let horizX = cropView.frame.maxX - 45
    let horizY = cropView.frame.maxY + 15
    let horiz = CGPoint(x: horizX, y: horizY)
    path.addLine(to: horiz)

    return path.cgPath
  }

  func bottomLeftPath() -> CGPath {
    let path = UIBezierPath()

    let horiz0X = cropView.frame.minX + 45
    let horiz0Y = cropView.frame.maxY + 15
    let horiz0 = CGPoint(x: horiz0X, y: horiz0Y)
    path.move(to: horiz0)

    let horizNX = cropView.frame.minX + 15
    let horizNY = cropView.frame.maxY + 15
    let horizN = CGPoint(x: horizNX, y: horizNY)
    path.addLine(to: horizN)

    let arcCenterX = cropView.frame.minX + 15
    let arcCenterY = cropView.frame.maxY - 15
    let arcCenter = CGPoint(x: arcCenterX, y: arcCenterY)
    path.addArc(center: arcCenter, startAngle: .pi/2)

    let vertX = cropView.frame.minX - 15
    let vertY = cropView.frame.maxY - 45
    let vert = CGPoint(x: vertX, y: vertY)
    path.addLine(to: vert)

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
