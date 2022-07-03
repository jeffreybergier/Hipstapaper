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

import SwiftUI
import Umbrella
import V3Model
import V3Store

internal struct FormSingle: View {
    
    @Nav private var nav
    @WebData private var webData
    @WebsiteQuery private var item
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        Form {
            FormSingleRow(self.$item)
            self.goButton
            WebSnapshot(self.$item?.thumbnail)
        }
        .onLoadChange(of: self.identifier) {
            _item.identifier = $0
        }
        .onChange(of: self.webData.currentThumbnail) {
            self.item?.thumbnail = $0?.pngData()
        }
        .onChange(of: self.webData.currentTitle) {
            self.item?.title = $0
        }
        .onChange(of: self.webData.currentURL) {
            self.item?.resolvedURL = $0
        }
    }
    
    private func mapURL(_ binding: Binding<URL?>) -> Binding<String?> {
        binding.map(get: { $0?.absoluteString }, set: { URL(string: $0 ?? "") })
    }
    
    private var goButton: some View {
        Button("Go") {
            self.nav.shouldLoadURL = self.item?.originalURL
        }
    }
}

fileprivate struct FormSingleRow: View {
    
    private let item: Binding<Website>?
    
    internal init(_ binding: Binding<Website>?) {
        self.item = binding
    }
    
    internal var body: some View {
        if let item {
            JSBTextField("Title",    text: item.title)
            JSBTextField("Original", text: item.originalURL.mapString)
            JSBTextField("Resolved", text: item.resolvedURL.mapString)
        } else {
            EmptyState()
        }
    }
}
