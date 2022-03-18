//
//  Created by Jeffrey Bergier on 2022/03/13.
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

@propertyWrapper
public struct QueryProperty: DynamicProperty {
    
    // For some reason Query as an entire object is not saving well.
    // Going to convert it to primitives manually.
    // TODO: Convert back into single scenestorage property
    @SceneStorage("Query.Tag") private var tag: String?
    @SceneStorage("Query.Sort") private var sort: String?
    @SceneStorage("Query.Search") private var search: String?
    @SceneStorage("Query.isOnlyNotArchived") private var isOnlyNotArchived: Bool?
    
    public init() {}
    
    public var wrappedValue: Query {
        get {
            Query(tag: self.tag.map { Tag.Ident($0) },
                  sort: self.sort.map { Sort(rawValue: $0) } ?? nil,
                  search: self.search,
                  isOnlyNotArchived: self.isOnlyNotArchived)
        }
        nonmutating set {
            self.tag = newValue.tag.id
            self.sort = newValue.sort.rawValue
            self.search = newValue.search
            self.isOnlyNotArchived = newValue.isOnlyNotArchived
        }
    }
    
    public var projectedValue: Binding<Query> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}
