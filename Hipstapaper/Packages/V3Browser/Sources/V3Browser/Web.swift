//
//  Created by Jeffrey Bergier on 2022/07/01.
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

import WebKit
import SwiftUI
import Umbrella
import V3Store

internal struct Web: View {
    
    @Navigation private var nav
    @StateObject private var progress = ObserveBox<Double>(0)
    
    internal var body: some View {
        ZStack(alignment: .top) {
            _Web(progress: self.progress)
                .ignoresSafeArea()
            ProgressView(value: self.progress.value, total: 1)
                .opacity(self.nav.isLoading ? 1 : 0)
                .animation(.default, value: self.progress.value)
                .animation(.default, value: self.nav.isLoading)
        }
    }
}

fileprivate struct _Web: View {
    
    @Navigation   private var nav
    @ErrorStorage private var errors

    @ObservedObject fileprivate var progress: ObserveBox<Double>
    @StateObject private var kvo = SecretBox(Array<NSObjectProtocol>())

    private func update(_ wv: WKWebView, context: Context) {
        if self.nav.shouldStop {
            wv.stopLoading()
            _nav.HACK_set(\.shouldStop, false)
        }
        if self.nav.shouldReload {
            wv.reload()
            _nav.HACK_set(\.shouldReload, false)
        }
        if self.nav.shouldGoBack {
            wv.goBack()
            _nav.HACK_set(\.shouldGoBack, false)
        }
        if self.nav.shouldGoForward {
            wv.goForward()
            _nav.HACK_set(\.shouldGoForward, false)
        }
        if wv.configuration.defaultWebpagePreferences.allowsContentJavaScript != self.nav.isJSEnabled {
            wv.configuration.defaultWebpagePreferences.allowsContentJavaScript = self.nav.isJSEnabled
            wv.reload()
        }
        if let load = self.nav.shouldLoadURL {
            wv.load(URLRequest(url: load))
            _nav.HACK_set(\.shouldLoadURL, nil)
        }
    }
        
    private func makeWebView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = self.nav.isJSEnabled
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.configuration.websiteDataStore = .nonPersistent()
        wv.navigationDelegate = context.coordinator
        let token1 = wv.observe(\.isLoading)
        { wv, _ in
            MainActor.assumeIsolated {
                self.nav.isLoading = wv.isLoading
            }
        }
        let token2 = wv.observe(\.url)
        { wv, _ in
            MainActor.assumeIsolated {
                self.nav.currentURL = wv.url
            }
        }
        let token3 = wv.observe(\.title)
        { wv, _ in
            MainActor.assumeIsolated {
                self.nav.currentTitle = wv.title ?? ""
            }
        }
        let token4 = wv.observe(\.estimatedProgress)
        { wv, _ in
            MainActor.assumeIsolated {
                self.progress.value = wv.estimatedProgress
            }
        }
        let token5 = wv.observe(\.canGoBack)
        { wv, _ in
            MainActor.assumeIsolated {
                self.nav.canGoBack = wv.canGoBack
            }
        }
        let token6 = wv.observe(\.canGoForward)
        { wv, _ in
            MainActor.assumeIsolated {
                self.nav.canGoForward = wv.canGoForward
            }
        }
        self.kvo.value = [token1, token2, token3, token4, token5, token6]
        return wv
    }
    
    func makeCoordinator() -> GenericWebKitNavigationDelegate {
        return .init { [errors] error in
            errors.append(error)
        }
    }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
extension _Web: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        return self.makeWebView(context: context)
    }
    
    func updateNSView(_ wv: WKWebView, context: Context) {
        self.update(wv, context: context)
    }
}
#else
extension _Web: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        return self.makeWebView(context: context)
    }
    
    func updateUIView(_ wv: WKWebView, context: Context) {
        self.update(wv, context: context)
    }
}
#endif
