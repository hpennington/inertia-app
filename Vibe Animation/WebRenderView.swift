import SwiftUI
import WebKit

struct WKWebViewWrapper: NSViewRepresentable {
    let url: URL
    let contentController: WKUserContentController
    
    init(url: URL, contentController: WKUserContentController) {
        self.url = url
        self.contentController = contentController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(contentController: contentController)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        contentController.add(context.coordinator, name: "consoleHandler")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.underPageBackgroundColor = .black
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{
            nsView.load(request)
            
            nsView.navigationDelegate = context.coordinator
        })
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let contentController: WKUserContentController
        
        init(contentController: WKUserContentController) {
            self.contentController = contentController
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let consoleLogSetup = """
            (function() {
                const console = window.console;
                function intercept(method) {
                    const original = console[method];
                    console[method] = function() {
                        var message = {
                            type: method,
                            args: Array.prototype.slice.call(arguments)
                        };
                        window.webkit.messageHandlers.consoleHandler.postMessage(message);
                        if (original.apply) {
                            original.apply(console, arguments);
                        } else {
                            var messageText = Array.prototype.slice.call(arguments).join(' ');
                            original(messageText);
                        }
                    }
                }
                ['log', 'error', 'warn', 'info'].forEach(function(method) {
                    intercept(method);
                })
            })()
            """

            webView.evaluateJavaScript(consoleLogSetup) { value, error in
                if let error {
                    print(error)
                    return
                }
                
                if let value {
                    print(value)
                }
                
                guard let vibeScriptURL = Bundle.main.url(forResource: "vibe", withExtension: "js") else {
                    print("failed to load vibe.js from Bundle.main")
                    return
                }
                
                guard let vibeScriptContents = try? String(contentsOf: vibeScriptURL, encoding: .utf8) else {
                    print("Failed to parse file contents of URL: \(vibeScriptURL)")
                    return
                }

                webView.evaluateJavaScript(vibeScriptContents) { value, error in
                    if let error {
                        print(error)
                        return
                    }
                    
                    if let value {
                        print(value)
                    }
                }
            }
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
    
    var body: some View {
        WKWebViewWrapper(url: url, contentController: WKUserContentController())
    }
}
