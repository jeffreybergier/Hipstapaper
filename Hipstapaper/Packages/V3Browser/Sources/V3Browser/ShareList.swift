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
    
    internal enum Data {
        case saved(URL), current(URL)
    }
    
    @V3Style.ShareList private var style
    @V3Localize.BrowserShareList private var text
    @Environment(\.dismiss) private var dismiss
    
    private let data: [Data]
    
    internal init(_ data: [Data]) {
        self.data = data
    }
    
    internal var body: some View {
        NavigationStack {
            Form {
                self.data.view { data in
                    ForEach(data) { item in
                        switch item {
                        case .saved(let url):
                            self.shareLink(url: url,
                                           text: self.text.shareSaved,
                                           copy: self.text.copy)
                        case .current(let url):
                            self.shareLink(url: url,
                                           text: self.text.shareCurrent,
                                           copy: self.text.copy)
                        }
                    }
                } onEmpty: {
                    self.style.disabled(subtitle: self.text.shareErrorSubtitle)
                        .action(text: self.text.error)
                        .label
                }
                
            }
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
        ShareLink(item: url) {
            HStack {
                self.style.enabled(subtitle: url.absoluteString)
                    .action(text: text)
                    .label
                self.style.copy.action(text: copy).button {
                    JSBPasteboard.set(url: url)
                }
            }
        }
    }
}

internal struct ShareListPresentation: ViewModifier {
    @Navigation private var nav
    internal func body(content: Content) -> some View {
        content.popover(items: self.$nav.isShareList) {
            ShareList($0)
        }
    }
}

extension ShareList.Data: Identifiable {
    var id: URL {
        switch self {
        case .current(let url): fallthrough
        case .saved(let url): return url
        }
    }
}
