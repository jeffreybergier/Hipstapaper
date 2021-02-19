
//
//  Created by Jeffrey Bergier on 2020/12/05.
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

struct WebView: View {
    
    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject private var errorQ: ErrorQueue
    
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
        { [unowned viewModel, weak wv] timer in
            guard let wv = wv else { timer.invalidate(); return; }
            guard viewModel.control.shouldLoad else { return }
            wv.snap_takeSnapshot(with: viewModel.thumbnailConfiguration) { viewModel.output.thumbnail = $0 }
        }
        self.viewModel.kvo = [token1, token2, token3, token4]
        return wv
    }
    
    func makeCoordinator() -> STZ.ERR.WKDelegate {
        return .init(viewModel: self.errorQ) { [unowned viewModel] _ in
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
