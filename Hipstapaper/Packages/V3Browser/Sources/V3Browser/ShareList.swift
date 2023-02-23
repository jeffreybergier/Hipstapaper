//
//  Created by Jeffrey Bergier on 2022/08/20.
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
import V3Style
import V3Localize

internal struct ShareList: View {
    
    internal struct Data: Identifiable {
        internal var id = UUID().uuidString
        internal var current: URL?
        internal var saved: URL?
        internal var isEmpty: Bool {
            self.current == nil && self.saved == nil
        }
        internal var sameURL: URL? {
            guard self.current == self.saved else { return nil }
            return self.current
        }
    }
    
    @V3Style.ShareList private var style
    @HACK_macOS_Style private var hack_style
    @V3Localize.BrowserShareList private var text
    @V3Localize.ShareList private var text_shareList
    @Environment(\.dismiss) private var dismiss
    
    private let data: Data
    
    internal init(_ data: Data) {
        self.data = data
    }
    
    internal var body: some View {
        NavigationStack {
            JSBForm {
                if self.data.isEmpty {
                    self.style.disabled(subtitle: self.text.shareErrorSubtitle)
                        .action(text: self.text.error)
                        .label
                } else if let saved = self.data.sameURL {
                    self.shareLink(url: saved,
                                   text: self.text.shareSaved,
                                   copy: self.text.copy)
                } else {
                    if let current = self.data.current {
                        self.shareLink(url: current,
                                       text: self.text.shareCurrent,
                                       copy: self.text.copy)
                    }
                    if let saved = self.data.saved {
                        self.shareLink(url: saved,
                                       text: self.text.shareSaved,
                                       copy: self.text.copy)
                    }
                }
                
            }
            .modifier(self.hack_style.formStyle)
            .modifier(JSBToolbar(title: self.text.title,
                                 done: self.text.done,
                                 doneAction: self.dismiss.callAsFunction))
        }
        .modifier(self.style.popoverSize)
    }
    
    private func shareLink(url: URL,
                           text: ActionLocalization,
                           copy: ActionLocalization)
                           -> some View
    {
        self.style.shareLink(itemURLs: [url],
                             itemTitle: text,
                             itemSubtitle: self.text_shareList.itemSubtitle([url]),
                             copyTitle: copy)
        {
            JSBPasteboard.set(url: url)
        }
    }
}

internal struct ShareListPresentation: ViewModifier {
    @Navigation private var nav
    internal func body(content: Content) -> some View {
        content.popover(item: self.$nav.isShareList) {
            ShareList($0)
        }
    }
}
