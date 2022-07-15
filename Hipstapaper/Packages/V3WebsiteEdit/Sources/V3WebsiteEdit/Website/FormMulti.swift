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
import V3Style
import V3Localize

internal struct FormMulti: View {
    
    private let selection: Website.Selection
    
    internal init(_ selection: Website.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        Form {
            ForEach(Array(self.selection)) { ident in
                FormSection(ident)
            }
            .modifier(EmptyMod(self.selection.isEmpty))
        }
    }
}

fileprivate struct FormSection: View {
    
    @WebsiteQuery private var item
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        EmptyView(value: self.$item) { item in
            Section {
                TextField(self.text.websiteTitle, text: item.title.compactMap())
                TextField(self.text.originalURL, text: item.originalURL.mapString())
                    .textContentTypeURL
                TextField(self.text.resolvedURL, text: item.resolvedURL.mapString())
                    .textContentTypeURL
                if let thumbnail = item.thumbnail.wrappedValue {
                    self.style.deleteThumbnail.button(self.text.deleteThumbnail) {
                        item.thumbnail.wrappedValue = nil
                    }
                    Image(data: thumbnail)?
                        .resizable()
                        .modifier(self.style.thumbnail)
                        .frame(width: 128, height: 128)
                }
            } header: {
                JSBText(self.text.untitled, text: item.title.wrappedValue)
            }
        }
        .onLoadChange(of: self.identifier) {
            _item.setIdentifier($0)
        }
    }
}
