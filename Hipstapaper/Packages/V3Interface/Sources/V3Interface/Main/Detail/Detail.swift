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

internal struct Detail: View {
    
    @Nav private var nav
    @QueryProperty private var query
    @WebsiteListQuery private var data
    
    @TagUserQuery private var tag: Tag?
    @State private var selection = Set<Website.Identifier>()
    
    internal var body: some View {
        NavigationStack {
            Table(self.data, selection: self.$selection, sortOrder: self.$query.sort) {
                TableColumn("Title", sortUsing: .titleA) { item in
                    JSBText("Untited", text: item.title)
                }
                TableColumn("URL") { item in
                    JSBText("No URL", text: item.preferredURL?.absoluteString)
                }
                TableColumn("Date Added", sortUsing: .dateCreatedNewest) { item in
                    JSBText("No Date", text: "\(item.dateCreated ?? Date(timeIntervalSince1970: 0))")
                }
                TableColumn("Date Modified", sortUsing: .dateModifiedNewest) { item in
                    JSBText("No Date", text: "\(item.dateModified ?? Date(timeIntervalSince1970: 0))")
                }
            }
            .modifier(.detailTitle(self.$tag?.name))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Text("X")
                }
                ToolbarItem(placement: .secondaryAction) {
                    Text("Y")
                }
            }
            .toolbarRole(.editor)
        }
        .onLoadChange(of: self.query) {
            _data.query = $0
        }
        .onLoadChange(of: self.nav.selectedTags) {
            _data.identifier = $0
        }
    }
}
