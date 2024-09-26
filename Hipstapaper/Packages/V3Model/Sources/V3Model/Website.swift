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

import Foundation

public struct Website: Identifiable, Hashable, Equatable {
    
    public typealias Selection = Set<Website.Identifier>

    public struct Identifier: Codable, Hashable, Identifiable, Sendable {
        public var id: RawIdentifier
        internal var HACK_websiteID = "THIS IS A HACK TO PREVENT DECODING CONFLICTS"
        public init(_ rawValue: String) {
            self.id = .init(rawValue)
        }
        public init(_ rawValue: RawIdentifier) {
            self.id = rawValue
        }
    }
    
    public var id: Identifier
    public var isArchived: Bool
    public var originalURL: URL?
    public var resolvedURL: URL?
    public var title: String?
    public var thumbnail: Data?
    public var dateCreated: Date?
    public var dateModified: Date?
    
    public init(id: Identifier,
                isArchived: Bool = false,
                originalURL: URL? = nil,
                resolvedURL: URL? = nil,
                title: String? = nil,
                thumbnail: Data? = nil,
                dateCreated: Date? = nil,
                dateModified: Date? = nil)
    {
        self.id = id
        self.isArchived = isArchived
        self.originalURL = originalURL
        self.resolvedURL = resolvedURL
        self.title = title
        self.thumbnail = thumbnail
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
}

extension Website {
    public var preferredURL: URL? { self.resolvedURL ?? self.originalURL }
}

extension Website.Identifier: Comparable {
    public static func < (lhs: Website.Identifier, rhs: Website.Identifier) -> Bool {
        return lhs.id.rawValue < rhs.id.rawValue
    }
}
