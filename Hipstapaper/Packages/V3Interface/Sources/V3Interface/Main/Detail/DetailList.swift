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
import V3Store

internal struct DetailList: View {
    
    @Nav private var nav
    @Query private var query
    @WebsiteListQuery private var data
    
    internal var body: some View {
        List(self.data, selection: self.$nav.detail.selectedWebsites) { item in
            WebsiteListRow(item.id)
        }
        .searchable(text: self.$query.search, prompt: "Search")
        .onLoadChange(of: self.query) {
            _data.query = $0
        }
        .onLoadChange(of: self.nav.sidebar.selectedTag) {
            _data.containsTag = $0
        }
    }
}

internal struct WebsiteListRow: View {
    
    @WebsiteQuery private var item
    private let id: Website.Selection.Element
    
    internal init(_ id: Website.Selection.Element) {
        self.id = id
    }
    
    internal var body: some View {
        HStack {
            VStack(alignment: .leading) {
                JSBText("Untitled", text: self.item?.title)
                JSBText("No Date", text: self.item?.dateCreated?.description)
            }
            Spacer()
            Image(systemName: "photo.circle")
        }
        .onLoadChange(of: self.id) {
            _item.identifier = $0
        }
    }
}
