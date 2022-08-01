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

internal struct ShareList: View {
    
    @Controller private var controller
    @Environment(\.dismiss) private var dismiss
    
    @State private var allItems: [URL] = []
    
    private let selection: Website.Selection
    private let selectionA: Array<Website.Selection.Element>
    
    internal init(_ selection: Website.Selection) {
        self.selection = selection
        self.selectionA = Array(selection)
    }
    
    internal var body: some View {
        NavigationStack {
            Form {
                if self.allItems.isEmpty == false {
                    ShareLink(items: self.allItems) {
                        Label("All Items", systemImage: "square.and.arrow.up.on.square")
                    }
                }
                self.selectionA.view {
                    ForEach($0) { identifier in
                        ShareListRow(identifier)
                    }
                } onEmpty: {
                    Text("Nothing Selected")
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
        JSBToolbar(title: "Share",
                   done: "Done",
                   doneAction: self.dismiss.callAsFunction)
    }
}

internal struct ShareListRow: View {
    
    @WebsiteQuery private var item
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        self.itemURL.view { url in
            ShareLink(item: url) {
                self.shareLabel(title: self.item?.title, url: url)
            }
        } onNIL: {
            self.noShareLabel(title: self.item?.title)
        }
        .font(.body)
        .lineLimit(1)
        .onLoadChange(of: self.identifier) {
            _item.setIdentifier($0)
        }
    }
    
    // TODO: For V3Style
    // func shareLink(_ item: Item) return shareLabel
    // func shareLink() -> return noShareLabel
    // func shareLink(_ items: [URL]) return all items share link or nothing
    
    private var itemURL: URL? {
        self.item?.preferredURL
    }
    
    private func shareLabel(title: String?, url: URL) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                JSBText("Untitled", text: title)
                Text(url.absoluteString)
                    .font(.caption)
            }
        } icon: {
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    private func noShareLabel(title: String?) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                JSBText("Untitled", text: title)
                Text("No URL")
                    .font(.caption)
            }
        } icon: {
            Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
        }
        .tint(Color.gray)
        .foregroundColor(Color.gray)
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
