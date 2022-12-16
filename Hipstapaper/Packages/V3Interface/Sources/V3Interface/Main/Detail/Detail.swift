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
import Umbrella

internal struct Detail: View {
    
    @Navigation private var nav
    @Selection private var selection
    @Query private var query
    @BulkActions private var state
    @FAST_WebsiteListQuery private var data
    
    @V3Localize.Detail private var text
    @V3Style.Detail private var style
    @HACK_EditMode private var isEditMode
    
    internal var body: some View {
        NavigationStack {
            self.selection.tag.view { _ in
                self.data.view {
                    DetailTable($0)
                } onEmpty: {
                    self.style.disabled
                        .action(text: self.text.noWebsites)
                        .label
                }
                .searchable(text: self.$query.search,
                            prompt: self.text.search)
                .onLoadChange(of: self.query) {
                    _data.setQuery($0)
                }
                .onLoadChange(of: self.selection.tag) {
                    _data.setFilter($0)
                }
                .onLoadChange(of: self.selection.websites) {
                    guard self.isEditMode == false, $0.count == 1 else { return }
                    self.nav.detail.isBrowse = $0.first
                }
            } onNIL: {
                self.style.disabled.action(text: self.text.noTagSelected).label
            }
        }
        .modifier(DetailMenu())
        .modifier(DetailTitle())
        .modifier(DetailToolbar())
        .modifier(BrowserSheet(self.$nav.detail.isBrowse))
        .modifier(ShareListSheet(self.$nav.detail.isShare))
        .modifier(WebsiteEditSheet(self.$nav.detail.isTagApply, start: .tag))
    }
}
