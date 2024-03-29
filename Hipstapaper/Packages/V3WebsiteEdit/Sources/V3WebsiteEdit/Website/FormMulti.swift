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
    
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    
    private let selection: [(offset: Int, element: Website.Selection.Element)]
    
    internal init(_ selection: Website.Selection) {
        self.selection = Array(selection.enumerated())
    }
    
    internal var body: some View {
        self.selection.view { selection in
            ForEach(selection, id: \.element) { index, identifier in
                FormSection(identifier)
                #if os(macOS)
                if index != selection.count - 1 {
                    Divider()
                        .padding([.top, .bottom], nil)
                }
                #endif
            }
        } onEmpty: {
            self.style.disabled.action(text: self.text.noWebsitesSelected).label
        }
    }
}

fileprivate struct FormSection: View {
    
    @WebsiteQuery private var query
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    @HACK_macOS_Style private var hack_style
    
    @State private var originalURLMirror: String = ""
    @State private var resolvedURLMirror: String = ""
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        self.$query.view { item in
            Section {
                TextField(self.text.formTitle, text: item.title.compactMap())
                TextField(
                    self.text.formOriginalURL,
                    text: item.originalURL.mirror(string: self.$originalURLMirror)
                ).textContentTypeURL
                TextField(
                    self.text.formResolvedURL,
                    text: item.resolvedURL.mirror(string: self.$resolvedURLMirror)
                ).textContentTypeURL
                if let thumbnail = item.thumbnail.wrappedValue {
                    self.style.form.action(text: self.text.deleteThumbnail).button {
                        item.thumbnail.wrappedValue = nil
                    }
                    self.style.thumbnailMulti(thumbnail)
                }
            } header: {
                JSBText(self.text.dataUntitled, text: item.title.wrappedValue)
            }
        } onNIL: {
            self.style.disabled.action(text: self.text.noWebsites).label
        }
        .onChange(of: self.identifier, initial: true) { _, newValue in
            self.query.identifier = newValue
        }
    }
}
