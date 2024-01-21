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
    
    @Navigation private var nav
    @WebState private var webState
    @WebsiteQuery private var query
    @ErrorStorage private var errors
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerToken: Cancellable?
    @State private var originalURLMirror: String = ""
    @State private var resolvedURLMirror: String = ""
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        self.$query.view { item in
            Section {
                self.originalURLRow(item)
            }
            Section {
                TextField(self.text.formTitle, text: item.title.compactMap())
                TextField(
                    self.text.formResolvedURL,
                    text: item.resolvedURL.mirror(string: self.$resolvedURLMirror)
                ).textContentTypeURL
                self.rowDeleteThumbnail(item)
                self.style.thumbnailSingle(self.query.data?.thumbnail) { Web() }
            }
        } onNIL: {
            self.style.disabled.action(text: self.text.noWebsitesSelected).label
        }
        .animation(.default, value: self.nav.isQRCodeScan)
        .onChange(of: self.identifier, initial: true) { _, newValue in
            self.query.identifier = newValue
        }
        .onChange(of: self.webState.currentThumbnail, initial: false) { _, newImage in
            guard let newImage else { return }
            self.$query?.wrappedValue.setThumbnail(newImage)
        }
        .onChange(of: self.webState.currentTitle, initial: false) { _, newValue in
            self.$query?.wrappedValue.title = newValue
        }
        .onChange(of: self.webState.currentURL, initial: false) { _, newValue in
            self.$query?.wrappedValue.resolvedURL = newValue
        }
        .onChange(of: self.nav.shouldLoadURL, initial: false) { _, newValue in
            guard newValue != nil else { return }
            self.timerStart()
        }
        .onChange(of: self.nav.isError, initial: false) { _, newValue in
            // If there is an error, stop the timer.
            // Otherwise, snapshots continue to attempt to be taken,
            // which continues to produce more errors
            guard newValue != nil else { return }
            self.timerStop()
        }
        .onReceive(self.timer) { _ in
            self.nav.shouldSnapshot = true
        }
    }
    #if canImport(QRScanner)
    @ViewBuilder private func originalURLRow(_ item: Binding<Website>) -> some View {
        VStack(spacing: self.style.verticalSpacingQRScan) {
            HStack(spacing: self.style.horizontalSpacingQRScan) {
                Button(self.text.buttonTitleQR, systemImage: self.text.buttonSymbolQR) {
                    self.nav.isQRCodeScan.toggle()
                }
                TextField(
                    self.text.formOriginalURL,
                    text: item.originalURL.mirror(string: self.$originalURLMirror)
                ).textContentTypeURL
            }
            if self.nav.isQRCodeScan {
                QRScan { result in
                    self.nav.isQRCodeScan = false
                    switch result {
                    case .success(let urlString):
                        item.wrappedValue.originalURL = URL(string: urlString)
                    case .failure(let error):
                        self.errors.append(error)
                    }
                }
            }
        }
        self.rowAutofill(item)
        self.rowJavascript
    }
    #else
    @ViewBuilder private func originalURLRow(_ item: Binding<Website>) -> some View {
        TextField(
            self.text.formOriginalURL,
            text: item.originalURL.mirror(string: self.$originalURLMirror)
        ).textContentTypeURL
        self.rowAutofill(item)
        self.rowJavascript
    }
    #endif
    
    @ViewBuilder private func rowAutofill(_ item: Binding<Website>) -> some View {
        if self.nav.isLoading {
            self.style.toolbar.action(text: self.text.stop).button {
                self.nav.shouldStop = true
            }
        } else {
            self.style.toolbar
                      .action(text: self.text.autofill)
                      .button(item: item.wrappedValue.originalURL)
            {
                self.nav.shouldLoadURL = $0
            }
        }
    }
    
    @ViewBuilder private func rowDeleteThumbnail(_ item: Binding<Website>) -> some View {
        if item.wrappedValue.thumbnail != nil {
            self.style.form.action(text: self.text.deleteThumbnail).button {
                item.wrappedValue.thumbnail = nil
                self.nav.shouldStop = true
                self.timerStop()
            }
        }
    }
    
    private var rowJavascript: some View {
        if self.nav.isJSEnabled {
            return self.style.toolbar.action(text: self.text.jsYes).button {
                self.nav.isJSEnabled = false
            }
        } else {
            return self.style.toolbar.action(text: self.text.jsNo).button {
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
