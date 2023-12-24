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
    
    @Query private var query
    @Navigation private var nav
    @Selection private var selection
    
    @V3Style.DetailTable private var style
    @V3Localize.DetailTable private var text
    @V3Style.ShowsTable private var showsTable
    
    @State private var HACK_tableSelection: Set<Website.Identifier.RawIdentifier> = []

    private let data: C
    
    internal init(_ data: C) {
        self.data = data
    }
    
    internal var body: some View {
        self.tableMulti
    }
    
    internal var tableMulti: some View {
        Table(of: Website.Identifier.self,
              selection: self.$HACK_tableSelection,
              sortOrder: self.$query.sort.HACK_mapSort
        )
        {
            self.column1Thumbnail
            self.column2Title
            self.column3URL
            self.column4DateCreated
        } rows: {
            ForEach(self.data) {
                TableRow($0)
            }
        }
        // TODO: HACK: Keep the system selection and table selection in sync
        .onChange(of: self.HACK_tableSelection) { _, tableSelection in
            let newValue = Set(tableSelection.map { Website.Identifier($0) })
            guard self.selection.websites != newValue else { return }
            self.selection.websites = newValue
            print("Table Selection Changed")
        }
        // TODO: HACK: Keep the system selection and table selection in sync
        .onChange(of: self.selection.websites, initial: true) { _, systemSelection in
            let newValue = Set(systemSelection.map { $0.id })
            guard HACK_tableSelection != newValue else { return }
            self.HACK_tableSelection = newValue
            print("System Selection Changed")
        }
    }
    
    private var column1Thumbnail: HACK_ColumnUnsorted<some View> {
        // TODO: Put the column title back when its possible to hide the title
        // TableColumn(self.text.columnThumbnail) {
        return TableColumn("") {
            switch self.showsTable {
            case .showTable:
                DetailTableColumnThumbnail($0)
            case .showList:
                DetailTableColumnCompact($0)
            }
        }
        .width(self.showsTable == .showTable
               ? self.style.columnWidthThumbnail
               : nil)
    }
    
    private var column2Title: HACK_ColumnSorted<some View> {
        TableColumn(self.text.columnTitle, sortUsing: .title) {
            DetailTableColumnTitle($0)
        }
    }
    
    private var column3URL: HACK_ColumnUnsorted<some View> {
        TableColumn(self.text.columnURL) {
            DetailTableColumnURL($0)
        }
    }
    
    private var column4DateCreated: HACK_ColumnSorted<some View> {
        TableColumn(self.text.columnDateCreated, sortUsing: .dateCreated) {
            DetailTableColumnDate(id: $0, kp: \.dateCreated)
        }
        .width(self.style.columnWidthDate)
    }
}

// Shortcuts to make it easier to tell the columns which Keypath they represent
extension KeyPathComparator {
    fileprivate static var title: KeyPathComparator<Website.Identifier> { .init(\Website.Identifier.title) }
    fileprivate static var dateCreated: KeyPathComparator<Website.Identifier> { .init(\Website.Identifier.dateCreated) }
    fileprivate static var dateModified: KeyPathComparator<Website.Identifier> { .init(\Website.Identifier.dateModified) }
}
