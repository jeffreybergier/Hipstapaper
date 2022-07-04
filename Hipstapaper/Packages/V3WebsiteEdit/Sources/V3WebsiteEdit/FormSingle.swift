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
    @V3Style.Browser private var style
    @V3Localize.Browser private var text

    @State private var timer = Timer.publish(every: 5, on: .main, in: .common)
    @State private var timerToken: Cancellable?
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        Form {
            self.rowEditForm
            self.rowAutofill
            self.rowWebSnapshot
            self.rowDeleteButton
            self.rowResolvedURL
        }
        .animation(.default, value: self.nav.isLoading)
        .onLoadChange(of: self.identifier) {
            _item.identifier = $0
        }
        .onChange(of: self.webState.currentThumbnail) {
            self.item?.thumbnail = $0?.pngData()
        }
        .onChange(of: self.webState.currentTitle) {
            self.item?.title = $0
        }
        .onChange(of: self.webState.currentURL) {
            self.item?.resolvedURL = $0
        }
        .onChange(of: self.nav.shouldLoadURL) {
            guard $0 != nil else { return }
            self.timerToken = self.timer.connect()
        }
        .onReceive(self.timer) { _ in
            self.nav.shouldSnapshot = true
        }
    }
    
    @ViewBuilder private var rowEditForm: some View {
        if let item = self.$item {
            TextField("Title",    text: item.title.compactMap())
            TextField("Address", text: item.originalURL.mapString())
        } else {
            EmptyState()
        }
    }
    
    @ViewBuilder private var rowResolvedURL: some View {
        if let item = self.$item {
            TextField("Loaded Address", text: item.resolvedURL.mapString())
        }
    }
    
    private var rowWebSnapshot: some View {
        ZStack {
            Web()
            Image(data: self.item?.thumbnail)?.resizable()
        }
        .frame(width: 320, height: 320)
    }
    
    @ViewBuilder private var rowAutofill: some View {
        if self.nav.isLoading {
            self.style.stop.button(self.text.stop) {
                self.nav.shouldStop = true
            }
        } else {
            Button {
                self.nav.shouldLoadURL = self.item?.originalURL
            } label: {
                Label("Autofill", systemImage: "wand.and.stars")
            }
        }
    }
    
    @ViewBuilder private var rowDeleteButton: some View {
        if self.item?.thumbnail != nil {
            Button("Delete Thumbnail") {
                self.item?.thumbnail = nil
                self.timerToken?.cancel()
                self.timer = Timer.publish(every: 5, on: .main, in: .common)
            }
        }
    }
    
    private func mapURL(_ binding: Binding<URL?>) -> Binding<String?> {
        binding.map(get: { $0?.absoluteString }, set: { URL(string: $0 ?? "") })
    }
}
