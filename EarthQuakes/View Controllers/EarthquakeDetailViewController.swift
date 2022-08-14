import WebKit
import UIKit

final class EarthquakeDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    internal var website: String? {
        didSet {
            if let websiteString = website, let url = URL(string: websiteString) {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    // MARK: - Elements
    
    private lazy var webView: WKWebView = {
        return createBaseWebView()
    }()
    
    // MARK: - Actions
    
    @objc
    private func pullToRefresh() {
        webView.reloadFromOrigin()
        webView.scrollView.refreshControl?.endRefreshing()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(webView)
        setupPullToRefresh(scrollView: webView.scrollView)
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
    }
    
    // MARK: - WebView Creation
    
    private func createBaseWebView() -> WKWebView {
        let config = makeWebViewConfig()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsLinkPreview = true
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        // Turning off masking allows the web content to flow outside of the scrollView's frame
        // which allows the content appear beneath the toolbars in the BrowserViewController
        webView.scrollView.layer.masksToBounds = false
            
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }
    
    private func makeWebViewConfig() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = [.all]
        let userContentController = WKUserContentController()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        return configuration
    }
    
    private func setupPullToRefresh(scrollView: UIScrollView?) {
        guard let scrollView = scrollView else {return}
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
}
