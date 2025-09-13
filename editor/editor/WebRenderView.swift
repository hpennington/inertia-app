import SwiftUI
import WebKit

struct WKWebViewWrapper: NSViewRepresentable, Equatable {
    static func ==(lhs: WKWebViewWrapper, rhs: WKWebViewWrapper) -> Bool {
        return lhs.url.path(percentEncoded: true) == rhs.url.path(percentEncoded: true)
    }
    
    let url: URL
    let webView: WKWebView
    let coordinator: Coordinator
    
    init(url: URL, webView: WKWebView, coordinator: Coordinator) {
        self.url = url
        self.webView = webView
        self.coordinator = coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    func makeNSView(context: Context) -> WKWebView {
        webView.isInspectable = true
        webView.configuration.userContentController.removeAllScriptMessageHandlers()
        webView.configuration.userContentController.add(context.coordinator, name: "inertiaMessageBusHandler")
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if self.url != context.coordinator.currentURL {
            let request = URLRequest(url: url)
            WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: {
                nsView.navigationDelegate = context.coordinator
                nsView.load(request)
                
            })
            context.coordinator.currentURL = self.url
        }
    }
    
    struct InertiaMessageBusBody: Codable {
        let id: String
        let isSelected: Bool
    }
    
    @Observable
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let selectedActionableIDTracker: SelectedActionableIDTracker
        
        var currentURL: URL? = nil
        private weak var webView: WKWebView?
        
        init(selectedActionableIDTracker: SelectedActionableIDTracker) {
            self.selectedActionableIDTracker = selectedActionableIDTracker
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
            self.webView = webView
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "consoleHandler", let messageBody = message.body as? [String: Any] {
                if let type = messageBody["type"] as? String, let args = messageBody["args"] as? [Any] {
                    print("Console \(type):", args)
                }
            } else if message.name == "inertiaMessageBusHandler" {
                guard let data = try? JSONSerialization.data(withJSONObject: message.body) else {
                    print("Failed to encode data")
                    return
                }
                
                guard let busMessage = try? JSONDecoder().decode(InertiaMessageBusBody.self, from: data) else {
                    print("Failed to decode the InertiaMEssageBusBody")
                    return
                }
                
                let contains = selectedActionableIDTracker.selectedActionableIds.contains(busMessage.id)
                
                if busMessage.isSelected && !contains {
                    selectedActionableIDTracker.selectedActionableIds.insert(busMessage.id)
                } else if !busMessage.isSelected && contains {
                    selectedActionableIDTracker.selectedActionableIds.remove(busMessage.id)
                }
            }
        }
    }
}

struct WebRenderView: View, Equatable {
    static func ==(lhs: WebRenderView, rhs: WebRenderView) -> Bool {
        return lhs.url.path(percentEncoded: true) == rhs.url.path(percentEncoded: true)
    }
    
    let url: URL
    let contentController: WKUserContentController
    let coordinator: WKWebViewWrapper.Coordinator
    let webView: WKWebView
    
    var body: some View {
        WKWebViewWrapper(url: url, webView: webView, coordinator: coordinator)
            .equatable()
            .id(url.absoluteString)
    }
}
