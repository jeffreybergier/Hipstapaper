//
//  Created by Jeffrey Bergier on 2022/06/26.
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
import V3Localize
import V3Style

// TODO: Remove C if `any RandomAccessCollection<Website>` ever works
internal struct DetailList<C: RandomAccessCollection>: View where C.Element == Website.Selection.Element {

    @Nav private var nav
    private let data: C
    
    internal init(_ data: C) {
        self.data = data
    }
    
    internal var body: some View {
        List(self.data,
             id: \.self,
             selection: self.$nav.detail.selectedWebsites)
        { identifier in
            WebsiteListRow(identifier)
        }
        .listStyle(.plain)
    }
}

import V3Store

internal struct WebsiteListRow: View {
    
    @WebsiteQuery private var item
    @V3Style.Detail private var style
    @V3Localize.Detail private var text

    private let id: Website.Selection.Element
    
    internal init(_ id: Website.Selection.Element) {
        self.id = id
    }
    
    internal var body: some View {
        HStack {
            VStack(alignment: .leading) {
                JSBText(self.text.missingTitle, text: self.item?.title)
                JSBText(self.text.missingURL, text: self.item?.preferredURL?.prettyValue)
                JSBText(self.text.missingDate, text: _text.dateString(self.item?.dateCreated))
            }
            .modifier(self.style.lineLimitList)
            Spacer()
            self.style.thumbnail(self.item?.thumbnail)
        }
        .onLoadChange(of: self.id) {
            _item.setIdentifier($0)
        }
    }
}
