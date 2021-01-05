//
//  Created by Jeffrey Bergier on 2020/12/20.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import WebKit

internal struct WebView: View {
    
    internal class Control: ObservableObject {
        @Published var stop = false
        @Published var reload = false
        @Published var goBack = false
        @Published var goForward = false
        @Published var isJSEnabled = false
        @Published var load: URL?
        let originalLoad: URL
        internal init(_ load: URL) {
            self.load = load
            self.originalLoad = load
        }
        deinit {
            // TODO: Remove once toolbar leaks are fixed
            print("Browser Control DEINIT")
        }
    }
    
    internal class Display: ObservableObject {
        var titleChanged: ((String) -> Void)?
        @Published var title: String = "" {
            didSet {
                self.titleChanged?(self.title)
            }
        }
        @Published var currentURLString = ""
        @Published var isLoading: Bool = false
        @Published var canGoBack: Bool = false
        @Published var canGoForward: Bool = false
        let progress = Progress(totalUnitCount: 100)
        var kvo: [NSKeyValueObservation] = []
        deinit {
            // TODO: Remove once toolbar leaks are fixed
            print("Browser Display DEINIT")
        }
    }
    
    @ObservedObject var control: Control
    @ObservedObject var display: Display
    
    private func update(_ wv: WKWebView, context: Context) {
        if self.control.stop {
            wv.stopLoading()
            self.control.stop = false
        }
        if self.control.reload {
            wv.reload()
            self.control.reload = false
        }
        if self.control.goBack {
            wv.goBack()
            self.control.goBack = false
        }
        if self.control.goForward {
            wv.goForward()
            self.control.goForward = false
        }
        if wv.configuration.preferences.javaScriptEnabled != self.control.isJSEnabled {
            wv.configuration.preferences.javaScriptEnabled = self.control.isJSEnabled
            wv.reload()
        }
        if let load = self.control.load {
            wv.load(URLRequest(url: load))
            self.control.load = nil
        }
    }
        
    private func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        let token1 = wv.observe(\.isLoading)
        { [unowned display] wv, _ in
            display.isLoading = wv.isLoading
        }
        let token2 = wv.observe(\.url)
        { [unowned display] wv, _ in
            display.currentURLString = wv.url?.absoluteString ?? ""
        }
        let token3 = wv.observe(\.title)
        { [unowned display] wv, _ in
            display.title = wv.title ?? ""
        }
        let token4 = wv.observe(\.estimatedProgress)
        { [unowned display] wv, two in
            display.progress.completedUnitCount = Int64(wv.estimatedProgress * 100)
        }
        let token5 = wv.observe(\.canGoBack)
        { [unowned display] wv, _ in
            display.canGoBack = wv.canGoBack
        }
        let token6 = wv.observe(\.canGoForward)
        { [unowned display] wv, _ in
            display.canGoForward = wv.canGoForward
        }
        self.display.kvo = [token1, token2, token3, token4, token5, token6]
        return wv
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
