//
//  Created by Jeffrey Bergier on 2022/07/30.
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
import V3Localize
import V3Style

internal struct DetailListRow: View {
    
    @WebsiteQuery private var item
    @V3Style.DetailList private var style
    @V3Localize.DetailList private var text

    private let id: Website.Selection.Element
    
    internal init(_ id: Website.Selection.Element) {
        self.id = id
    }
    
    internal var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                JSBText(self.text.missingTitle, text: self.item?.title)
                    .modifier(self.style.title)
                switch self.style.accessibilityMode {
                case false:
                    self.dateSiteDefault
                case true:
                    self.dateSiteAccessible
                }
            }
            Spacer()
            self.style.thumbnail(self.item?.thumbnail)
        }
        .onLoadChange(of: self.id, async: true) {
            _item.setIdentifier($0)
        }
    }
    
    private var dateSiteDefault: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            JSBText(self.text.missingDate, text: _text.dateString(self.item?.dateCreated))
                .modifier(self.style.date)
            Text("•")
                .modifier(self.style.date)
            JSBText(self.text.missingURL, text: self.item?.preferredURL?.prettyValueHost)
                .modifier(self.style.url)
        }
    }
    
    private var dateSiteAccessible: some View {
        VStack(alignment: .leading, spacing: 4) {
            JSBText(self.text.missingURL, text: self.item?.preferredURL?.prettyValueHost)
                .modifier(self.style.url)
            JSBText(self.text.missingDate, text: _text.dateString(self.item?.dateCreated))
                .modifier(self.style.date)
        }
    }
}
