
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

struct WebView: View {
    
    struct Input {
        var shouldLoad: Bool = false
        var originalURL: URL?
    }
    
    class Output: ObservableObject {
        @Published var isLoading: Bool = false {
            didSet {
                print("isLoading: \(isLoading)")
            }
        }
        @Published var resolvedURL: URL? {
            didSet {
                print("resolvedURL: \(resolvedURL)")
            }
        }
        @Published var title: String? {
            didSet {
                print("title: \(title)")
            }
        }
        var kvo = [NSKeyValueObservation]()
    }

    
    @Binding var input: Input
    var output: Output
    
    init(input: Binding<Input>, output: Output) {
        _input = input
        self.output = output
    }
    
    private func update(_ wv: WKWebView, context: Context) {
        guard self.input.shouldLoad else {
            wv.stopLoading()
            return
        }
        guard let originalURL = self.input.originalURL else { return }
        let request = URLRequest(url: originalURL)
        wv.load(request)
    }
    
    private func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        let token1 = wv.observe(\.isLoading) { _, _ in
            self.output.isLoading = wv.isLoading
        }
        let token2 = wv.observe(\.url) { _, _ in
            self.output.resolvedURL = wv.url
        }
        let token3 = wv.observe(\.title) { _, _ in
            self.output.title = wv.title
        }
        self.output.kvo = [token1, token2, token3]
        return wv
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
