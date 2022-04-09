//
//  Created by Jeffrey Bergier on 2020/12/05.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Collections
import SwiftUI
import WebKit
import Umbrella
import Datum

struct WebView: View {

    @Binding internal var website: Website
    @Binding internal var control: Control
    
    // TODO: Update to modern error env
    @State private var errorQ = Deque<UserFacingError>()
    @State private var kvo: [NSKeyValueObservation] = []
    
    private func update(_ wv: WKWebView, context: Context) {
        if self.control.isJSEnabled != wv.configuration.preferences.javaScriptEnabled {
            wv.configuration.preferences.javaScriptEnabled = self.control.isJSEnabled
            self.control.shouldLoad = true
            wv.reload()
            return
        }
        
        guard self.control.shouldLoad else {
            wv.stopLoading()
            return
        }
        
        guard
            let originalURL = self.website.originalURL,
            !wv.isLoading
        else { return }
        
        let request = URLRequest(url: originalURL)
        wv.load(request)
    }
    
    private func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = self.control.isJSEnabled
        config.mediaTypesRequiringUserActionForPlayback = .all
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.configuration.websiteDataStore = .nonPersistent()
        wv.navigationDelegate = context.coordinator
        wv.allowsBackForwardNavigationGestures = false
        let token1 = wv.observe(\.isLoading)
        { wv, _ in
            self.control.isLoading = wv.isLoading
        }
        let token2 = wv.observe(\.url)
        { wv, _ in
            self.website.resolvedURL = wv.url
        }
        let token3 = wv.observe(\.title)
        { wv, _ in
            self.website.title = wv.title
        }
        let token4 = wv.observe(\.estimatedProgress)
        { wv, _ in
            self.control.pageLoadProgress.completedUnitCount = Int64(wv.estimatedProgress * 100)
        }
        self.control.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true)
        { [weak wv] timer in
            guard let wv = wv else { timer.invalidate(); return; }
            guard self.control.shouldLoad else { return }
            wv.snap_takeSnapshot(with: self.control.configuration) {
                // TODO: Capture error
                self.website.thumbnail = $0.value
            }
        }
        self.kvo = [token1, token2, token3, token4]
        return wv
    }
    
    func makeCoordinator() -> GenericWebKitNavigationDelegate {
        return .init(self.errorQ) { error in
            self.control.shouldLoad = false
            // TODO: Capture error
        }
    }
}

#if canImport(AppKit)

import AppKit

extension WebView: NSViewRepresentable {
    func updateNSView(_ wv: WKWebView, context: Context) {
        self.update(wv, context: context)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let wv = self.makeWebView(context: context)
        wv.pageZoom = 0.7
        wv.allowsMagnification = false
        return wv
    }
}

#endif

#if canImport(UIKit)

import UIKit

extension WebView: UIViewRepresentable {
    func updateUIView(_ wv: WKWebView, context: Context) {
        self.update(wv, context: context)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let wv = self.makeWebView(context: context)
        wv.transform = .init(scaleX: 0.7, y: 0.7)
        wv.isUserInteractionEnabled = false
        return wv
    }
}
#endif
