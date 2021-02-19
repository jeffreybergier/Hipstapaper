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
import Umbrella
import Stylize

internal struct WebView: View {
    
    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject private var errorQ: ErrorQueue
    
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
    
    func makeCoordinator() -> STZ.ERR.WKDelegate {
        return .init(viewModel: self.errorQ)
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
