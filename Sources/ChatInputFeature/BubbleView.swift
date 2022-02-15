import UIKit

public final class BubbleView<Content: UIView>: UIView {
    private let content: Content
    private let padding: CGFloat

    public init(_ content: Content, padding: CGFloat = 0) {
        self.content = content
        self.padding = padding
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        layer.cornerRadius = 4
        clipsToBounds = true
        addSubview(content)

        content.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(padding)
            make.bottom.trailing.equalToSuperview().offset(-padding)
        }
    }
}
