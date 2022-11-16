import UIKit

public final class UnselectableTextView: UITextView {
  public override var selectedTextRange: UITextRange? {
    get { return nil }
    set {}
  }
  
  public override func point(
    inside point: CGPoint,
    with event: UIEvent?
  ) -> Bool {
    guard let pos = closestPosition(to: point) else { return false }
    guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else { return false }
    
    let startIndex = offset(from: beginningOfDocument, to: range.start)
    return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
  }
}
