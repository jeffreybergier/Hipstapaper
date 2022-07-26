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
    @V3Style.Detail private var style
    @V3Localize.Detail private var text
    
    private let data: C
    
    internal init(_ data: C) {
        self.data = data
    }
    
    internal var body: some View {
        Table(selection: self.$nav.detail.selectedWebsites,
              sortOrder: self.$query.sort.mapTable)
        {
            TableColumn(self.text.columnThumbnail) {
                DetailTableColumnThumbnail($0.id)
            }
            TableColumn(self.text.columnTitle, sortUsing: title) {
                DetailTableColumnTitle($0.id)
            }
            TableColumn(self.text.columnURL) {
                DetailTableColumnURL($0.id)
            }
            TableColumn(self.text.columnDateCreated, sortUsing: dateCreated) {
                DetailTableColumnDate(id: $0.id, kp: \.dateCreated)
            }
            TableColumn(self.text.columnDateModified, sortUsing: dateModified) {
                DetailTableColumnDate(id: $0.id, kp: \.dateModified)
            }
        } rows: {
            ForEach(self.data) {
                TableRow(HACK_FakeIdentifierWrapper($0))
            }
        }
    }
}

// TODO: Clean these up and move them into their own file
import V3Store

internal struct DetailTableColumnThumbnail: View {
    
    @WebsiteQuery private var item
    @V3Style.Detail private var style
    private let id: Website.Identifier
    
    internal init(_ id: Website.Identifier) {
        self.id = id
    }
    
    var body: some View {
        self.style.thumbnail(self.item?.thumbnail)
            .onLoadChange(of: self.id) {
                _item.setIdentifier($0)
            }
    }
}

internal struct DetailTableColumnTitle: View {
    
    @WebsiteQuery private var item
    @V3Localize.Detail private var text
    
    private let id: Website.Identifier
    
    internal init(_ id: Website.Identifier) {
        self.id = id
    }
    
    var body: some View {
        JSBText(self.text.missingTitle, text: self.item?.title)
            .onLoadChange(of: self.id) {
                _item.setIdentifier($0)
            }
    }
}

internal struct DetailTableColumnURL: View {
    
    @WebsiteQuery private var item
    @V3Localize.Detail private var text
    
    private let id: Website.Identifier
    
    internal init(_ id: Website.Identifier) {
        self.id = id
    }
    
    var body: some View {
        JSBText(self.text.missingURL,
                text: self.item?.preferredURL?.absoluteString)
            .onLoadChange(of: self.id) {
                _item.setIdentifier($0)
            }
    }
}

internal struct DetailTableColumnDate: View {
    
    @WebsiteQuery private var item
    @V3Localize.Detail private var text
    
    private let id: Website.Identifier
    private let keyPath: KeyPath<Website, Date?>
    
    internal init(id: Website.Identifier, kp: KeyPath<Website, Date?>) {
        self.id = id
        self.keyPath = kp
    }
    
    var body: some View {
        JSBText(self.text.missingDate,
                text: _text.dateString(self.item?[keyPath: self.keyPath]))
        .onLoadChange(of: self.id) {
            _item.setIdentifier($0)
        }
    }
}

extension Binding where Value == Sort {
    fileprivate var mapTable: Binding<[KeyPathComparator<HACK_FakeIdentifierWrapper>]> {
        self.map { value in
            switch value {
            case .dateCreatedNewest:
                return [.init(\.dateCreated, order: .reverse)]
            case .dateCreatedOldest:
                return [.init(\.dateCreated, order: .forward)]
            case .dateModifiedNewest:
                return [.init(\.dateModified, order: .reverse)]
            case .dateModifiedOldest:
                return [.init(\.dateModified, order: .forward)]
            case .titleA:
                return [.init(\.title, order: .reverse)]
            case .titleZ:
                return [.init(\.title, order: .forward)]
            }
        } set: {
            guard let newValue = $0.first else { return .default }
            switch (newValue.keyPath, newValue.order) {
            case (\.title, .reverse):
                return .titleA
            case (\.title, .forward):
                return .titleZ
            case (\.dateCreated, .reverse):
                return .dateCreatedNewest
            case (\.dateCreated, .forward):
                return .dateCreatedOldest
            case (\.dateModified, .reverse):
                return .dateModifiedNewest
            case (\.dateModified, .forward):
                return .dateModifiedOldest
            default:
                return .default
            }
        }
    }
}

// TODO: Delete when possible
// Table does not appear to let you choose how you identify
// the object. It always chooses the ID property for what it is passed.
// This is a problem when I am passing the identifier itself.
fileprivate struct HACK_FakeIdentifierWrapper: Identifiable {
    internal var id: Website.Identifier
    internal init(_ id: Website.Identifier) {
        self.id = id
    }
}

extension HACK_FakeIdentifierWrapper {
    fileprivate var title: Date? { fatalError() }
    fileprivate var dateModified: Date? { fatalError() }
    fileprivate var dateCreated: Date? { fatalError() }
}

fileprivate let title        = KeyPathComparator(\HACK_FakeIdentifierWrapper.title)
fileprivate let dateCreated  = KeyPathComparator(\HACK_FakeIdentifierWrapper.dateCreated)
fileprivate let dateModified = KeyPathComparator(\HACK_FakeIdentifierWrapper.dateModified)
