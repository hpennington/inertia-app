//
//  WebRenderView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/29/24.
//

import SwiftUI
import WebKit

struct WKWebViewWrapper: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        nsView.load(request)
    }
}


struct WebRenderView: View {
    var body: some View {
        WKWebViewWrapper(url: URL(string: "http://localhost:3000")!)
    }
}

#Preview {
    WebRenderView()
}
