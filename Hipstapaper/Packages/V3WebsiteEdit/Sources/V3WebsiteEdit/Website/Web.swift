//
//  Created by Jeffrey Bergier on 2022/07/03.
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

/// This browser is just used to generate a thumbnail image, so its best to always load the mobile version of the site.
/// This could be improved to include the users actual language and such and version... AKA just change the word macOS to iPhone.
/// But thats more work than I want to do right now.
fileprivate let kFakeUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"

internal struct Web: View {
    
    @Navigation private var nav
    @StateObject private var progress = ObserveBox<Double>(0)
    
    internal var body: some View {
        ZStack(alignment: .top) {
            _Web(progress: self.progress)
            ProgressView(value: self.progress.value, total: 1)
                .opacity(self.nav.isLoading ? 1 : 0)
                .animation(.default, value: self.progress.value)
                .animation(.default, value: self.nav.isLoading)
        }
    }
}

fileprivate struct _Web: View {
    
    @WebState     private var webState
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
        if self.nav.shouldSnapshot {
            _nav.HACK_set(\.shouldSnapshot, false)
            wv.snapshot { [errors, state = _webState.raw] result in
                switch result {
                case .success(let image):
                    state.value.currentThumbnail = image
                case .failure(let error):
                    errors.append(error)
                }
            }
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
        preferences.preferredContentMode = .mobile
        preferences.allowsContentJavaScript = self.nav.isJSEnabled
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.configuration.websiteDataStore = .nonPersistent()
        wv.navigationDelegate = context.coordinator
        wv.customUserAgent = kFakeUserAgent
        #if !os(macOS)
        wv.isUserInteractionEnabled = false
        #endif
        let token1 = wv.observe(\.isLoading)
        { wv, _ in
            MainActor.assumeIsolated {
                self.nav.isLoading = wv.isLoading
            }
        }
        let token2 = wv.observe(\.url) { wv, _ in
            MainActor.assumeIsolated {
                self.webState.currentURL = wv.url
            }
        }
        let token3 = wv.observe(\.title)
        { wv, _ in
            MainActor.assumeIsolated {
                self.webState.currentTitle = wv.title ?? ""
            }
        }
        let token4 = wv.observe(\.estimatedProgress)
        { wv, _ in
            MainActor.assumeIsolated {
                self.progress.value = wv.estimatedProgress
            }
        }
        self.kvo.value = [token1, token2, token3, token4]
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

extension WKWebView {
    fileprivate func snapshot(completion: @escaping (Result<JSBImage, Swift.Error>) -> Void) {
        self.takeSnapshot(with: nil) { image, error in
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(error))
                    return
                }
                completion(.success(image!))
            }
        }
    }
}
