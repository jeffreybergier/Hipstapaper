//
//  Created by Jeffrey Bergier on 2020/12/20.
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
import Localize

internal struct WebView: View {
    
    @ObservedObject var viewModel: ViewModel
    @ErrorQueue private var errorQ

    private func update(_ wv: WKWebView, context: Context) {
        if self.viewModel.browserControl.stop {
            wv.stopLoading()
            self.viewModel.browserControl.stop = false
        }
        if self.viewModel.browserControl.reload {
            wv.reload()
            self.viewModel.browserControl.reload = false
        }
        if self.viewModel.browserControl.goBack {
            wv.goBack()
            self.viewModel.browserControl.goBack = false
        }
        if self.viewModel.browserControl.goForward {
            wv.goForward()
            self.viewModel.browserControl.goForward = false
        }
        if wv.configuration.preferences.javaScriptEnabled != self.viewModel.itemDisplay.isJSEnabled {
            wv.configuration.preferences.javaScriptEnabled = self.viewModel.itemDisplay.isJSEnabled
            wv.reload()
        }
        if let load = self.viewModel.browserControl.load {
            wv.load(URLRequest(url: load))
            self.viewModel.browserControl.load = nil
        }
    }
        
    private func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.configuration.websiteDataStore = .nonPersistent()
        wv.navigationDelegate = context.coordinator
        let token1 = wv.observe(\.isLoading)
        { [unowned vm = viewModel] wv, _ in
            vm.browserDisplay.isLoading = wv.isLoading
        }
        let token2 = wv.observe(\.url)
        { [unowned vm = viewModel] wv, _ in
            vm.browserDisplay.urlString = wv.url?.absoluteString ?? ""
        }
        let token3 = wv.observe(\.title)
        { [unowned vm = viewModel] wv, _ in
            vm.browserDisplay.title = wv.title ?? ""
        }
        let token4 = wv.observe(\.estimatedProgress)
        { [unowned vm = viewModel] wv, _ in
            vm.browserDisplay.progress.completedUnitCount = Int64(wv.estimatedProgress * 100)
        }
        let token5 = wv.observe(\.canGoBack)
        { [unowned vm = viewModel] wv, _ in
            vm.browserDisplay.canGoBack = wv.canGoBack
        }
        let token6 = wv.observe(\.canGoForward)
        { [unowned vm = viewModel] wv, _ in
            vm.browserDisplay.canGoForward = wv.canGoForward
        }
        self.viewModel.browserDisplay.kvo = [token1, token2, token3, token4, token5, token6]
        return wv
    }
    
    func makeCoordinator() -> GenericWebKitNavigationDelegate {
        return .init(self._errorQ.environment.value)
    }
    
}

#if canImport(AppKit)
extension WebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        return self.makeWebView(context: context)
    }
    
    func updateNSView(_ wv: WKWebView, context: Context) {
        self.update(wv, context: context)
    }
}
#else
extension WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        return self.makeWebView(context: context)
    }
    
    func updateUIView(_ wv: WKWebView, context: Context) {
        self.update(wv, context: context)
    }
}
#endif
