import SwiftUI
import WebKit

struct WKWebViewWrapper: NSViewRepresentable {
    let url: URL
    let webView: WKWebView
    let selectedActionableIDTracker: SelectedActionableIDTracker
    
    init(url: URL, webView: WKWebView, selectedActionabeIDTracker: SelectedActionableIDTracker) {
        self.url = url
        self.webView = webView
        self.selectedActionableIDTracker = selectedActionabeIDTracker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedActionabeIDTracker: selectedActionableIDTracker)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        webView.isInspectable = true
        webView.configuration.userContentController.add(context.coordinator, name: "vibeMessageBusHandler")
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
    
    struct VibeMessageBusBody: Codable {
        let id: String
        let isSelected: Bool
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let selectedActionabeIDTracker: SelectedActionableIDTracker
        
        @State var currentURL: URL? = nil
        
        init(selectedActionabeIDTracker: SelectedActionableIDTracker) {
            self.selectedActionabeIDTracker = selectedActionabeIDTracker
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {

        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "consoleHandler", let messageBody = message.body as? [String: Any] {
                if let type = messageBody["type"] as? String, let args = messageBody["args"] as? [Any] {
                    print("Console \(type):", args)
                }
            } else if message.name == "vibeMessageBusHandler" {
                guard let data = try? JSONSerialization.data(withJSONObject: message.body) else {
                    print("Failed to encode data")
                    return
                }
                
                guard let busMessage = try? JSONDecoder().decode(VibeMessageBusBody.self, from: data) else {
                    print("Failed to decode the VibeMEssageBusBody")
                    return
                }
                
                let contains = selectedActionabeIDTracker.selectedActionableIds.contains(busMessage.id)
                
                if busMessage.isSelected && !contains {
                    selectedActionabeIDTracker.selectedActionableIds.insert(busMessage.id)
                } else if !busMessage.isSelected && contains {
                    selectedActionabeIDTracker.selectedActionableIds.remove(busMessage.id)
                }
            }
        }
    }
}

struct WebRenderView: View {
    static func ==(lhs: WebRenderView, rhs: WebRenderView) -> Bool {
        true
    }
    
    let url: URL
    let contentController: WKUserContentController
    let selectedActionabeIDTracker: SelectedActionableIDTracker
    let webView: WKWebView
    
    var body: some View {
        WKWebViewWrapper(url: url, webView: webView, selectedActionabeIDTracker: selectedActionabeIDTracker)
    }
}
