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

public struct Query: Codable, Hashable {
    
    public static let systemAll: Query = .init(isOnlyNotArchived: false)
    public static let systemUnread: Query = .init(isOnlyNotArchived: true)
    public static let `default`: Query = Self.systemUnread
    public static let noMatches: Query = .init(noPredicate: true)
    
    public var sort: [Sort]
    public var search: String
    public var isOnlyNotArchived: Bool
    /// Set to `true` if you want your query to return no matches despite other values.
    // TODO: Hack for performance reasons
    public var isNOPredicate = false
    
    internal init(sort: Sort? = nil,
                  search: String? = nil,
                  isOnlyNotArchived: Bool?)
    {
        self.sort = sort.map { [$0] } ?? [.default]
        self.search = search ?? ""
        self.isOnlyNotArchived = isOnlyNotArchived ?? true
    }
    
    internal init(noPredicate: Bool) {
        self.isNOPredicate = true
        self.sort = []
        self.search = ""
        self.isOnlyNotArchived = false
    }
}
