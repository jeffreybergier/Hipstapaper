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

import Combine
import SwiftUI
import Umbrella
import V3Model
import V3Store
import V3Style
import V3Localize

internal struct FormSingle: View {
    
    @Nav private var nav
    @WebState private var webState
    @WebsiteQuery private var item
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerToken: Cancellable?
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        Form {
            if self.item == nil {
                EmptyState()
            } else {
                self.form
            }
        }
        .onLoadChange(of: self.identifier) {
            _item.setIdentifier($0)
        }
        .onChange(of: self.webState.currentThumbnail) { image in
            guard let image else { return }
            self.item?.setThumbnail(image)
        }
        .onChange(of: self.webState.currentTitle) {
            self.item?.title = $0
        }
        .onChange(of: self.webState.currentURL) {
            self.item?.resolvedURL = $0
        }
        .onChange(of: self.nav.shouldLoadURL) {
            guard $0 != nil else { return }
            self.timerStart()
        }
        .onReceive(self.timer) { _ in
            self.nav.shouldSnapshot = true
        }
    }
    
    @ViewBuilder private var form: some View {
        self.rowEditForm
        self.rowAutofill
        self.rowWebSnapshot
        self.rowDeleteThumbnail
        self.rowJavascript
        self.rowResolvedURL
    }
    
    @ViewBuilder private var rowEditForm: some View {
        if let item = self.$item {
            TextField(self.text.websiteTitle, text: item.title.compactMap())
            TextField(self.text.originalURL, text: item.originalURL.mapString())
                .textContentTypeURL
        } else {
            EmptyState()
        }
    }
    
    @ViewBuilder private var rowResolvedURL: some View {
        if let item = self.$item {
            TextField(self.text.resolvedURL, text: item.resolvedURL.mapString())
                .textContentTypeURL
        }
    }
    
    private var rowWebSnapshot: some View {
        self.style.thumbnailSingle(self.item?.thumbnail) {
            Web()
        }
    }
    
    @ViewBuilder private var rowAutofill: some View {
        if self.nav.isLoading {
            self.style.stop.button(self.text.stop) {
                self.nav.shouldStop = true
            }
        } else {
            self.style.autofill.button(self.text.autofill,
                                       enabled: self.item?.preferredURL != nil)
            {
                self.nav.shouldLoadURL = self.item?.originalURL
            }
        }
    }
    
    @ViewBuilder private var rowDeleteThumbnail: some View {
        if self.item?.thumbnail != nil {
            self.style.deleteThumbnail.button(self.text.deleteThumbnail) {
                self.item?.thumbnail = nil
                self.nav.shouldStop = true
                self.timerStop()
            }
        }
    }
    
    private var rowJavascript: some View {
        if self.nav.isJSEnabled {
            return self.style.jsYes.button(self.text.jsYes) {
                self.nav.isJSEnabled = false
            }
        } else {
            return self.style.jsNo.button(self.text.jsNo) {
                self.nav.isJSEnabled = true
            }
        }
    }
    
    private func mapURL(_ binding: Binding<URL?>) -> Binding<String?> {
        binding.map(get: { $0?.absoluteString }, set: { URL(string: $0 ?? "") })
    }
    
    private func timerStop() {
        self.timerToken?.cancel()
        self.timerToken = nil
    }
    
    private func timerStart() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common)
        self.timerToken = self.timer.connect()
    }
}
