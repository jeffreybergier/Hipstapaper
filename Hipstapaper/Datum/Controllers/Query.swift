//
//  Created by Jeffrey Bergier on 2020/11/28.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public struct Query {
    public enum Archived: Int, Identifiable, CaseIterable {
        case unarchived, all
        public var id: ObjectIdentifier { .init(NSNumber(value: self.rawValue)) }
    }
    public var isArchived: Archived! // TODO: Hack for SwiftUI - Remove
    public var tag: AnyElement<AnyTag>?
    public var search: String {
        didSet {
            // TODO: Remove this print
            print(self.search)
        }
    }
    public var sort: Sort
    
    /// Use this initializer when the tag is selected from the UI
    /// and may include the static tags provided for `Unread` and `All`.
    /// This properly configures the Query in these special cases.
    public init(specialTag: AnyElement<AnyTag>) {
        self.init()
        switch specialTag {
        case Query.Archived.anyTag_allCases[0]:
            // Unread Items
            self.isArchived = .unarchived
        case Query.Archived.anyTag_allCases[1]:
            // All Items
            self.isArchived = .all
        default:
            // A user selected tag
            self.tag = specialTag
        }
    }

    public init(isArchived: Archived = .unarchived,
                tag: AnyElement<AnyTag>? = nil,
                search: String = "",
                sort: Sort = .dateModifiedNewest)
    {
        self.isArchived = isArchived
        self.tag = tag
        self.search = search
        self.sort = sort
    }
}
