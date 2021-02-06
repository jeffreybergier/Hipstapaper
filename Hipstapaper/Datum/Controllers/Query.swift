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
    
    public var filter: Filter! // TODO: Hack for SwiftUI - Remove
    public var tag: AnyElementObserver<AnyTag>?
    public var search: String
    public var sort: Sort! // TODO: Hack for SwiftUI - Remove
    
    /// Use this initializer when the tag is selected from the UI
    /// and may include the static tags provided for `Unread` and `All`.
    /// This properly configures the Query in these special cases.
    public init(specialTag: AnyElementObserver<AnyTag>) {
        self.init()
        switch specialTag {
        case Query.Filter.anyTag_allCases[0]:
            // Unread Items
            self.filter = .unarchived
        case Query.Filter.anyTag_allCases[1]:
            // All Items
            self.filter = .all
        default:
            // A user selected tag
            self.tag = specialTag
            self.filter = .all
        }
    }

    public init(isArchived: Filter = .unarchived,
                tag: AnyElementObserver<AnyTag>? = nil,
                search: String = "",
                sort: Sort = .default)
    {
        self.filter = isArchived
        self.tag = tag
        self.search = search
        self.sort = sort
    }
}

extension Query {
    public var isSearchActive: Bool {
        return self.search.nonEmptyString == nil
    }
    
    public enum Filter: Int, Identifiable, CaseIterable {
        case unarchived, all
        public var id: ObjectIdentifier { .init(NSNumber(value: self.rawValue)) }
        public var boolValue: Bool { return self == .unarchived }
    }
}
