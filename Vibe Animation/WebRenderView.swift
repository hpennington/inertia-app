import SwiftUI
import WebKit

struct WKWebViewWrapper: NSViewRepresentable {
    let url: URL
    let webView: WKWebView
    
    init(url: URL, webView: WKWebView) {
        self.url = url
        self.webView = webView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> WKWebView {
        webView.isInspectable = true
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: {
            nsView.load(request)
            nsView.navigationDelegate = context.coordinator
        })
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "consoleHandler", let messageBody = message.body as? [String: Any] {
                if let type = messageBody["type"] as? String, let args = messageBody["args"] as? [Any] {
                    print("Console \(type):", args)
                }
            }
        }
    }
}

struct WebRenderView: View {
    let url: URL
    let contentController: WKUserContentController
    let webView: WKWebView
    
    var body: some View {
        WKWebViewWrapper(url: url, webView: webView)
    }
}
