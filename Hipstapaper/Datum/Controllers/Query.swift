//
//  Created by Jeffrey Bergier on 2020/11/28.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
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

import Foundation
import Umbrella

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
        return self.search.trimmed == nil
    }
    
    public enum Filter: Int, Identifiable, CaseIterable {
        case unarchived, all
        public var id: ObjectIdentifier { .init(NSNumber(value: self.rawValue)) }
        public var boolValue: Bool {
            get { return self == .unarchived }
            set { self = newValue ? .unarchived : .all }
        }
    }
}
