import UIKit
import WebKit

public final class WebsiteController: UIViewController {
  private lazy var webView = WKWebView()

  private let url: URL

  public init(_ string: String) {
    self.url = .init(string: string)!
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    view.addSubview(webView)

    webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.webView.load(URLRequest(url: self.url))
    }
  }
}
