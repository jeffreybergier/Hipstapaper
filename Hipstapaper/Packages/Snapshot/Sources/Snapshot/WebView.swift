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

import SwiftUI
import WebKit
import Umbrella
import Collections

struct WebView: View {
    
    @ObservedObject var viewModel: ViewModel
    @State private var errorQ = Deque<UserFacingError>()
    
    private func update(_ wv: WKWebView, context: Context) {
        if self.viewModel.control.isJSEnabled != wv.configuration.preferences.javaScriptEnabled {
            wv.configuration.preferences.javaScriptEnabled = self.viewModel.control.isJSEnabled
            viewModel.control.shouldLoad = true
            wv.reload()
            return
        }
        
        guard self.viewModel.control.shouldLoad else {
            wv.stopLoading()
            return
        }
        
        guard
            self.viewModel.output.currentURL == nil,
            let originalURL = self.viewModel.output.inputURL,
            !wv.isLoading
        else { return }
        
        let request = URLRequest(url: originalURL)
        wv.load(request)
    }
    
    private func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = self.viewModel.control.isJSEnabled
        config.mediaTypesRequiringUserActionForPlayback = .all
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.configuration.websiteDataStore = .nonPersistent()
        wv.navigationDelegate = context.coordinator
        wv.allowsBackForwardNavigationGestures = false
        let token1 = wv.observe(\.isLoading)
        { [unowned viewModel] wv, _ in
            viewModel.isLoading = wv.isLoading
        }
        let token2 = wv.observe(\.url)
        { [unowned viewModel] wv, _ in
            viewModel.output.currentURL = wv.url
        }
        let token3 = wv.observe(\.title)
        { [unowned viewModel] wv, _ in
            viewModel.output.title = wv.title ?? ""
        }
        let token4 = wv.observe(\.estimatedProgress)
        { [unowned viewModel] wv, _ in
            viewModel.progress.completedUnitCount = Int64(wv.estimatedProgress * 100)
        }
        self.viewModel.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true)
        { [weak viewModel, weak wv] timer in
            guard let wv = wv, let viewModel = viewModel else { timer.invalidate(); return; }
            guard viewModel.control.shouldLoad else { return }
            wv.snap_takeSnapshot(with: viewModel.thumbnailConfiguration) { viewModel.output.thumbnail = $0 }
        }
        self.viewModel.kvo = [token1, token2, token3, token4]
        return wv
    }
    
    func makeCoordinator() -> GenericWebKitNavigationDelegate {
        return .init(self.errorQ) { [unowned viewModel] _ in
            viewModel.control.shouldLoad = false
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
