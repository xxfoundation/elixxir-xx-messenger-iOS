import UIKit
import WebKit

public final class WebScreen: UIViewController {
    lazy private(set) var webView = WebView()

    private var url: String!

    public init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }

    private func setupScreen() {
        view.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalToSuperview() }

        webView.webView.load(URLRequest(url: URL(string: url)!))
        webView.closeButton = UIBarButtonItem(title: "Close", style: .done, target: self,
                                              action: #selector(didTappedClose))
    }

    @objc private func didTappedClose() {
        dismiss(animated: true)
    }
}

final class WebView: UIView {

    let webView = WKWebView()
    let navBar = UINavigationBar()
    var closeButton: UIBarButtonItem! {
        didSet { navBar.topItem?.leftBarButtonItem = closeButton }
    }

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) { nil }

    private func setupLayout() {
        backgroundColor = .white
        navBar.items = [UINavigationItem(title: "")]
        addSubview(webView)
        addSubview(navBar)

        navBar.snp.makeConstraints { make -> Void in
            make.top.equalTo(safeAreaLayoutGuide)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        webView.snp.makeConstraints { make -> Void in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
        }
    }
}
