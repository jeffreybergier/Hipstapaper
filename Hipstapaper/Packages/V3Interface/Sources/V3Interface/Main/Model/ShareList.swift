//
//  Created by Jeffrey Bergier on 2022/08/01.
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

internal struct ShareList: View {
    
    @Controller private var controller
    @State private var allItems: [URL] = []
    
    @V3Style.ShareList private var style
    @V3Localize.ShareList private var text
    
    @Environment(\.dismiss) private var dismiss
        
    private let selection: Website.Selection
    private let selectionA: Array<Website.Selection.Element>
    
    internal init(_ selection: Website.Selection) {
        self.selection = selection
        self.selectionA = Array(selection)
    }
    
    internal var body: some View {
        NavigationStack {
            Form {
                self.allItems.view { urls in
                    ShareLink(items: urls) {
                        self.style.shareLabel(icon: .multi) {
                            Text(self.text.shareAll)
                        } subtitle: {
                            Text(self.text.itemsCount(urls.count))
                        }
                    }
                } onEmpty: {
                    self.style.shareLabel(icon: .error) {
                        Text(self.text.shareAll)
                    } subtitle: {
                        Text(self.text.shareError)
                    }
                }
                ForEach(self.selectionA) { identifier in
                    ShareListRow(identifier)
                }
            }
            .modifier(self.toolbar)
        }
        .frame(idealWidth: 320, idealHeight: 320)
        .onLoadChange(of: self.selection) {
            let result = BulkActionsQuery.openURL($0, self.controller)
            self.allItems = result.map { Array($0.multi) } ?? []
        }
    }
    
    private var toolbar: some ViewModifier {
        JSBToolbar(title: self.text.title,
                   done: self.text.done,
                   doneAction: self.dismiss.callAsFunction)
    }
}

internal struct ShareListRow: View {
    
    @WebsiteQuery private var item
    @V3Style.ShareList private var style
    @V3Localize.ShareList private var text
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        self.itemURL.view { url in
            ShareLink(item: url) {
                self.style.shareLabel(icon: .single) {
                    JSBText(self.text.untitled, text: self.item?.title)
                } subtitle: {
                    Text(url.absoluteString)
                }
            }
        } onNIL: {
            self.style.shareLabel(icon: .error) {
                JSBText(self.text.untitled, text: self.item?.title)
            } subtitle: {
                Text(self.text.shareError)
            }
        }
        .onLoadChange(of: self.identifier) {
            _item.setIdentifier($0)
        }
    }
    
    // Needed because Optional.View
    // does not work on chained optionals
    private var itemURL: URL? {
        self.item?.preferredURL
    }
}

internal struct ShareListPresentation: ViewModifier {
    
    @Nav private var nav

    internal func body(content: Content) -> some View {
        content.popover(items: self.$nav.detail.isShare)
        { selection in
            ShareList(selection)
                .presentationDetents([.medium])
        }
    }
}
