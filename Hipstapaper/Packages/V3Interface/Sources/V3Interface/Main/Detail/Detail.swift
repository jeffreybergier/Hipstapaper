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
import Umbrella
import V3Model
import V3Store
import V3Browser
import V3Localize

internal struct Detail: View {
    
    @Nav private var nav
    @Query private var query
    @WebsiteListQuery private var data
    
    @V3Localize.Detail private var text
    @JSBSizeClass private var sizeClass

    internal var body: some View {
        NavigationStack {
            self.data.view {
                switch self.sizeClass.horizontal {
                case .regular:
                    DetailTable($0)
                case .compact:
                    DetailList($0)
                }
            } onEmpty: {
                Text(self.text.emptyState)
            }
            .searchable(text: self.$query.search,
                        prompt: self.text.search)
            .onLoadChange(of: self.query) {
                _data.setQuery($0)
            }
            .onLoadChange(of: self.nav.sidebar.selectedTag) {
                _data.setFilter($0)
            }
            .modifier(DetailTitle())
            .modifier(DetailMenu())
            .modifier(DetailToolbar())
            .sheetCover(item: self.$nav.detail.isBrowse) { ident in
                Browser(ident)
            }
        }
    }
}
