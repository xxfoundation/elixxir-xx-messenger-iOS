import UIKit

public final class FlexibleSpace: UIView {
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setContentHuggingPriority(.defaultLow, for: .horizontal)
    setContentHuggingPriority(.defaultLow, for: .vertical)
    setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    setContentCompressionResistancePriority(.defaultLow, for: .vertical)
  }
  
  public convenience init() {
    self.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) { nil }
}
