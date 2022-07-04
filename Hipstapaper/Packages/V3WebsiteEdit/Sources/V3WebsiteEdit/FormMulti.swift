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

internal struct FormMulti: View {
    
    private let selection: Website.Selection
    @WebsiteSearchListQuery private var data
    
    internal init(_ selection: Website.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        Form {
            ForEach(self.$data) { item in
                Section {
                    TextField("Title",    text: item.title.compactMap())
                    TextField("Original", text: item.originalURL.mapString())
                    TextField("Resolved", text: item.resolvedURL.mapString())
                    ImageDelete(item.thumbnail)
                } header: {
                    JSBText("Untitled",      text: item.title.wrappedValue)
                }
            }
        }
        .onLoadChange(of: self.selection) {
            _data.search = $0
        }
    }
}

fileprivate struct ImageDelete: View {
    @Binding private var data: Data?
    internal init(_ binding: Binding<Data?>) {
        _data = binding
    }
    internal var body: some View {
        if let data {
            HStack {
                Image(data: data)?.resizable()
                    .frame(width: 128, height: 128)
                Spacer()
                Button("Delete Thumbnail") {
                    self.data = nil
                }
            }
        }
    }
}
