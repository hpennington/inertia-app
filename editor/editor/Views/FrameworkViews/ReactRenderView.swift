//
//  ReactRenderView.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI
import WebKit
import Inertia

struct ReactRenderView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var frameSize: CGSize?
    @Binding var servers: [SetupFlowFramework: WebSocketServer]

    let url: String
    let viewportMinimumSize: CGSize
    let renderViewportCornerRadius: CGFloat
    let contentController: WKUserContentController
    let coordinator: WKWebViewWrapper.Coordinator
    let webView: WKWebView
    let onKeyframeMessage: (WebSocketClient.MessageTranslation, InertiaAnimationValues?) -> Void
    var playheadTime: CGFloat

    private func maxCGSize(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }

    var body: some View {
        VStack {
            GeometryReader { proxy in
                if let url = URL(string: url) {
                    WebRenderView(
                        url: url,
                        contentController: contentController,
                        coordinator: coordinator,
                        webView: webView
                    )
                    .equatable()
                    .id(url)
                    .frame(width: 300)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(16 / 10, contentMode: .fit)
                    .background(Color.black)
                    .cornerRadius(renderViewportCornerRadius)
                    .padding(6 / 2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(colorScheme == .light ? ColorPalette.gray5 : ColorPalette.gray2, lineWidth: 6)
                    }
                    .onAppear {
                        frameSize = maxCGSize(lhs: proxy.size, rhs: viewportMinimumSize)
                    }
                    .onChange(of: proxy.size) { oldValue, newValue in
                        frameSize = maxCGSize(lhs: newValue, rhs: viewportMinimumSize)
                    }
                    .onAppear {
                        if servers[.react] == nil {
                            if let server = try? WebSocketServer(port: 8080) { message in
                                if playheadTime == .zero {
                                    let initialValues = InertiaAnimationValues(
                                        scale: 1.0,
                                        translate: .init(width: message.translationX, height: message.translationY),
                                        rotate: .zero,
                                        rotateCenter: .zero,
                                        opacity: 1.0
                                    )
                                    onKeyframeMessage(message, initialValues)
                                } else {
                                    onKeyframeMessage(message, nil)
                                }
                            } {
                                server.start()
                                servers[.react] = server
                            }
                        }
                    }
                } else {
                    Color.black
                }
                Spacer()
            }
        }
    }
}
