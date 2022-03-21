//
//  Created by Jeffrey Bergier on 2022/03/12.
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

public struct Website: Identifiable, Hashable, Codable {
    public var isArchived: Bool
    public var originalURL: URL?
    public var resolvedURL: URL?
    public var preferredURL: URL? { self.resolvedURL ?? self.originalURL }
    public var title: String?
    public var thumbnail: Data?
    
    public var id: String { self.uuid.id }
    public var uuid: Ident
    public var dateCreated: Date
    public var dateModified: Date
    
    public init(isArchived: Bool = false,
                originalURL: URL?,
                resolvedURL: URL?,
                title: String?,
                thumbnail: Data?,
                uuid: Ident,
                dateCreated: Date = Date(),
                dateModified: Date = Date())
    {
        self.isArchived = isArchived
        self.originalURL = originalURL
        self.resolvedURL = resolvedURL
        self.title = title
        self.thumbnail = thumbnail
        self.uuid = uuid
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
    
    public struct Ident: Identifiable, Hashable, Codable {
        public var id: String
        
        public init(_ id: String) {
            self.id = id
        }
    }
}
