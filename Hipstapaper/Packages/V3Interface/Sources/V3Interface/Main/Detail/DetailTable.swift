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
internal struct DetailTable<C: RandomAccessCollection>: View where C.Element == Website.Identifier {

    @Nav private var nav
    @Query private var query
    @V3Localize.Detail private var text
    @V3Style.Detail private var style

    private let data: C
    
    internal init(_ data: C) {
        self.data = data
    }
    
    internal var body: some View {
        switch self.query.sort {
        case .dateModifiedOldest, .dateModifiedNewest:
            self.tableDateModified
        default:
            self.tableDefault
        }
    }
    
    // TODO: Hack because of SwiftUI limitations
    // Closure containing control flow statement
    // cannot be used with result builder 'TableColumnBuilder'
    // I just want to change the column based on a current setting
    private var tableDefault: some View {
        Table(selection: self.$nav.detail.selectedWebsites,
              sortOrder: self.$query.sort.HACK_mapSort)
        {
            TableColumn(self.text.columnThumbnail) {
                DetailTableColumnThumbnail($0.id)
            }
            .width(self.style.thumbnailColumnWidth)
            TableColumn(self.text.columnTitle, sortUsing: .title) {
                DetailTableColumnTitle($0.id)
            }
            TableColumn(self.text.columnURL) {
                DetailTableColumnURL($0.id)
            }
            TableColumn(self.text.columnDateCreated, sortUsing: .dateCreated) {
                DetailTableColumnDate(id: $0.id, kp: \.dateCreated)
            }
            .width(max: self.style.dateColumnWidthMax)
        } rows: {
            ForEach(self.data) {
                TableRow(HACK_WebsiteIdentifier($0))
            }
        }
    }
    
    private var tableDateModified: some View {
        Table(selection: self.$nav.detail.selectedWebsites,
              sortOrder: self.$query.sort.HACK_mapSort)
        {
            TableColumn(self.text.columnThumbnail) {
                DetailTableColumnThumbnail($0.id)
            }
            .width(self.style.thumbnailColumnWidth)
            TableColumn(self.text.columnTitle, sortUsing: .title) {
                DetailTableColumnTitle($0.id)
            }
            TableColumn(self.text.columnURL) {
                DetailTableColumnURL($0.id)
            }
            TableColumn(self.text.columnDateModified, sortUsing: .dateModified) {
                DetailTableColumnDate(id: $0.id, kp: \.dateModified)
            }
            .width(max: self.style.dateColumnWidthMax)
        } rows: {
            ForEach(self.data) {
                TableRow(HACK_WebsiteIdentifier($0))
            }
        }
    }
}

// Shortcuts to make it easier to tell the columns which Keypath they represent
extension KeyPathComparator {
    fileprivate static var title: KeyPathComparator<HACK_WebsiteIdentifier> { .init(\HACK_WebsiteIdentifier.title) }
    fileprivate static var dateCreated: KeyPathComparator<HACK_WebsiteIdentifier> { .init(\HACK_WebsiteIdentifier.dateCreated) }
    fileprivate static var dateModified: KeyPathComparator<HACK_WebsiteIdentifier> { .init(\HACK_WebsiteIdentifier.dateModified) }
}
