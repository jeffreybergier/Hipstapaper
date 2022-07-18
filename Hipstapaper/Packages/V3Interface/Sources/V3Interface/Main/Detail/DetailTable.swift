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
internal struct DetailTable<C: RandomAccessCollection>: View where C.Element == Website {

    @Nav private var nav
    @Query private var query
    @V3Style.Detail private var style
    @V3Localize.Detail private var text
    
    private let data: C
    
    internal init(_ data: C) {
        self.data = data
    }
    
    internal var body: some View {
        Table(self.data,
              selection: self.$nav.detail.selectedWebsites,
              sortOrder: self.$query.sort.mapTable)
        {
            TableColumn(self.text.columnThumbnail)
            { item in
                self.style.thumbnail(item.thumbnail)
            }
            TableColumn(self.text.columnTitle,
                        sortUsing: title)
            { item in
                JSBText(self.text.missingTitle,
                        text: item.title)
            }
            TableColumn(self.text.columnURL)
            { item in
                JSBText(self.text.missingURL,
                        text: item.preferredURL?.absoluteString)
            }
            TableColumn(self.text.columnDateCreated,
                        sortUsing: dateCreated)
            { item in
                JSBText(self.text.missingDate,
                        text: _text.dateString(item.dateCreated))
            }
            TableColumn(self.text.columnDateModified,
                        sortUsing: dateModified)
            { item in
                JSBText(self.text.missingDate,
                        text: _text.dateString(item.dateModified))
            }
        }
    }
}

fileprivate let title        = KeyPathComparator(\Website.title)
fileprivate let dateCreated  = KeyPathComparator(\Website.dateCreated)
fileprivate let dateModified = KeyPathComparator(\Website.dateModified)

extension Binding where Value == Sort {
    fileprivate var mapTable: Binding<[KeyPathComparator<Website>]> {
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
