import UIKit
import WebKit
import AppResources

public final class WebsiteController: UIViewController {
  private lazy var webView = WKWebView()

  private let url: URL

  public init(_ string: String) {
    self.url = .init(string: string)!
    super.init(nibName: nil, bundle: nil)
  }

  public override func loadView() {
    let screenView = UIView()
    let navigationBar = UINavigationBar()
    navigationBar.isTranslucent = false
    navigationBar.backgroundColor = Asset.neutralLine.color

    screenView.addSubview(navigationBar)
    screenView.addSubview(webView)

    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    navigationBar.leftAnchor.constraint(equalTo: screenView.leftAnchor).isActive = true
    navigationBar.rightAnchor.constraint(equalTo: screenView.rightAnchor).isActive = true
    navigationBar.topAnchor.constraint(equalTo: screenView.safeAreaLayoutGuide.topAnchor).isActive = true

    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.leftAnchor.constraint(equalTo: screenView.leftAnchor).isActive = true
    webView.rightAnchor.constraint(equalTo: screenView.rightAnchor).isActive = true
    webView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
    webView.bottomAnchor.constraint(equalTo: screenView.bottomAnchor).isActive = true

    view = screenView
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
