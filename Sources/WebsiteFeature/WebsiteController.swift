import UIKit
import WebKit

public final class WebsiteController: UIViewController {
  private lazy var webView = WKWebView()

  private let url: URL

  public init(_ string: String) {
    self.url = .init(string: string)!
    super.init(nibName: nil, bundle: nil)
  }

  public override func loadView() {
    view = webView
  }

  required init?(coder: NSCoder) { nil }

  public override func viewDidLoad() {
    super.viewDidLoad()

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.webView.load(URLRequest(url: self.url))
    }
  }
}
