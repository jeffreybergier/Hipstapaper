//
//  Created by Jeffrey Bergier on 2022/06/17.
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
import V3Store
import V3Style
import V3Localize

internal struct Detail: View {
    
    @Navigation private var nav
    @Query private var query
    @BulkActions private var state
    @FAST_WebsiteListQuery private var data
    
    @V3Localize.Detail private var text
    @V3Style.Detail private var style
    @V3Style.ShowsTable private var showsTable
    
    internal var body: some View {
        NavigationStack {
            self.nav.sidebar.selectedTag.view { _ in
                self.data.view {
                    switch self.showsTable {
                    case .showTable:
                        DetailTable($0)
                    case .showList:
                        DetailList($0)
                    }
                } onEmpty: {
                    self.style.disabled.action(text: self.text.noWebsites).label
                }
                .searchable(text: self.$query.search,
                            prompt: self.text.search)
                .onLoadChange(of: self.query) {
                    _data.setQuery($0)
                }
                .onLoadChange(of: self.nav.sidebar.selectedTag) {
                    _data.setFilter($0)
                }
            } onNIL: {
                self.style.disabled.action(text: self.text.noTagSelected).label
            }
            .modifier(DetailTitle())
            .modifier(DetailMenu())
            .modifier(DetailToolbar())
            .modifier(BrowserSheet(self.$nav.detail.isBrowse))
            .modifier(ShareListSheet(self.$nav.detail.isShare))
            .modifier(WebsiteEditSheet(self.$nav.detail.isTagApply, start: .tag))
        }
    }
}
