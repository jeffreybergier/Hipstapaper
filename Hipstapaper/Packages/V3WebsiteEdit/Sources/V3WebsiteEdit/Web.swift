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

internal struct Web: View {
    
    @Nav private var nav
    @StateObject private var progress = BlackBox<Double>(0, isObservingValue: true)
    
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
    
    @Nav private var nav
    @WebState private var webState
    @Environment(\.errorResponder) private var errorChain
    @ObservedObject fileprivate var progress: BlackBox<Double>
    @StateObject private var kvo = BlackBox(Array<NSObjectProtocol>(),
                                            isObservingValue: false)

    private func update(_ wv: WKWebView, context: Context) {
        if self.nav.shouldStop {
            wv.stopLoading()
            self.nav.shouldStop = false
        }
        if self.nav.shouldReload {
            wv.reload()
            self.nav.shouldReload = false
        }
        if self.nav.shouldSnapshot {
            self.nav.shouldSnapshot = false
            wv.snapshot { [errorChain, state = _webState.raw] result in
                switch result {
                case .success(let image):
                    state.value.currentThumbnail = image
                case .failure(let error):
                    errorChain(error)
                }
            }
        }
        if wv.configuration.preferences.javaScriptEnabled != self.nav.isJSEnabled {
            wv.configuration.preferences.javaScriptEnabled = self.nav.isJSEnabled
            wv.reload()
        }
        if let load = self.nav.shouldLoadURL {
            wv.load(URLRequest(url: load))
            self.nav.shouldLoadURL = nil
        }
    }
        
    private func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.configuration.websiteDataStore = .nonPersistent()
        wv.navigationDelegate = context.coordinator
        wv.isUserInteractionEnabled = false
        let token1 = wv.observe(\.isLoading)
        { [unowned nav = _nav.raw] wv, _ in
            nav.value.isLoading = wv.isLoading
        }
        let token2 = wv.observe(\.url)
        { [unowned state = _webState.raw] wv, _ in
            state.value.currentURL = wv.url
        }
        let token3 = wv.observe(\.title)
        { [unowned state = _webState.raw] wv, _ in
            state.value.currentTitle = wv.title ?? ""
        }
        let token4 = wv.observe(\.estimatedProgress)
        { [unowned progress] wv, _ in
            progress.value = wv.estimatedProgress
        }
        self.kvo.value = [token1, token2, token3, token4]
        return wv
    }
    
    func makeCoordinator() -> GenericWebKitNavigationDelegate {
        return .init { [errorChain] error in
            errorChain(error)
        }
    }
    
}

#if canImport(AppKit)
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
    fileprivate func snapshot(completion: @escaping (Result<JSBImage, Error>) -> Void) {
        self.takeSnapshot(with: nil) { image, error in
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let image else {
                    // completion(.failure(error)) // TODO: Create error here
                    return
                }
                completion(.success(image))
            }
        }
    }
}
