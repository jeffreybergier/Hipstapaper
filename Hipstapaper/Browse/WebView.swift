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
    
    internal class ViewModel: ObservableObject {
        @Published var title: String = ""
        @Published var currentURLString = ""
        @Published var isLoading: Bool = false
        @Published var canGoBack: Bool = false
        @Published var canGoForward: Bool = false
        let progress = Progress(totalUnitCount: 100)
        let originalURL: URL
        var kvo: [NSKeyValueObservation] = []
        internal init(_ load: URL) {
            self.originalURL = load
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    
    private func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        let token1 = wv.observe(\.isLoading)
        { [unowned viewModel] wv, _ in
            viewModel.isLoading = wv.isLoading
        }
        let token2 = wv.observe(\.url)
        { [unowned viewModel] wv, _ in
            viewModel.currentURLString = wv.url?.absoluteString ?? ""
        }
        let token3 = wv.observe(\.title)
        { [unowned viewModel] wv, _ in
            viewModel.title = wv.title ?? ""
        }
        let token4 = wv.observe(\.estimatedProgress)
        { [unowned viewModel] wv, two in
            viewModel.progress.completedUnitCount = Int64(wv.estimatedProgress * 100)
        }
        self.viewModel.kvo = [token1, token2, token3, token4]
        return wv
    }
    
}

#if canImport(AppKit)
#else
extension WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        fatalError()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        fatalError()
    }
}
#endif
