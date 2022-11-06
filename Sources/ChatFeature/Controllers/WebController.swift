import UIKit
import WebKit

public final class WebScreen: UIViewController {
  private let url: URL
  private lazy var screenView = WebView()

  public init(_ urlString: String) {
    self.url = .init(string: urlString)!
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    screenView.webView.load(URLRequest(url: url))
    screenView.closeButton = UIBarButtonItem(
      title: "Close",
      style: .done,
      target: self,
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
    backgroundColor = .white
    navBar.items = [UINavigationItem(title: "")]
    addSubview(webView)
    addSubview(navBar)

    navBar.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
    }
    webView.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.top.equalTo(navBar.snp.bottom)
    }
  }

  required init?(coder: NSCoder) { nil }
}
