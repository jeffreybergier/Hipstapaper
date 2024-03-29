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

internal struct ShareListRow: View {
    
    @WebsiteQuery private var query
    @V3Style.ShareList private var style
    @V3Localize.ShareList private var text
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        self.itemURL.view { url in
            self.style.shareLink(
                itemURLs: [url],
                itemTitle: self.text.itemTitle(self.query.data?.title),
                itemSubtitle: self.text.itemSubtitle([url]),
                copyTitle: self.text.copy
            ){
                JSBPasteboard.set(title: self.query.data?.title, url: url)
            }
        } onNIL: {
            self.style.disabled(subtitle: self.text.shareErrorSubtitle)
                .action(text: self.text.errorTitle(self.query.data?.title))
                .label
        }
        .onChange(of: self.identifier, initial: true) { _, newValue in
            self.query.identifier = newValue
        }
    }
    
    // Needed because Optional.View
    // does not work on chained optionals
    private var itemURL: URL? {
        self.query.data?.preferredURL
    }
}
