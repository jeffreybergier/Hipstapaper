//
//  Created by Jeffrey Bergier on 2020/11/27.
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

import Combine

public struct AnyWebsite: Website {

    public typealias ID = ObjectIdentifier

    public var id:          ID      { _id() }
    public var isArchived:  Bool    { _isArchived() }
    public var originalURL: URL?    { _originalURL() }
    public var resolvedURL: URL?    { _resolvedURL() }
    public var preferredURL: URL?   { _preferredURL() }
    public var title:       String? { _title() }
    public var thumbnail:   Data?   { _thumbnail() }
    public var dateCreated: Date    { _dateCreated() }
    public var dateModified: Date   { _dateModified() }
    public func hash(into hasher: inout Hasher) { _hashValue(&hasher) }

    private let _id:           () -> ID
    private let _isArchived:   () -> Bool
    private let _originalURL:  () -> URL?
    private let _resolvedURL:  () -> URL?
    private let _preferredURL: () -> URL?
    private let _title:        () -> String?
    private let _thumbnail:    () -> Data?
    private var _dateCreated:  () -> Date
    private var _dateModified: () -> Date
    private var _hashValue:    (inout Hasher) -> ()

    /// Untyped storage for original database object
    internal let wrappedValue: Any

    public init<T: Website>(_ website: T) where T.ID == ID {
        _id = { website.id }
        _isArchived   = { website.isArchived }
        _originalURL  = { website.originalURL }
        _resolvedURL  = { website.resolvedURL }
        _preferredURL = { website.preferredURL }
        _title        = { website.title }
        _thumbnail    = { website.thumbnail }
        _dateCreated  = { website.dateCreated }
        _dateModified = { website.dateModified }
        _hashValue    = website.hash
        wrappedValue  = website
    }
    
    public static func == (lhs: AnyWebsite, rhs: AnyWebsite) -> Bool {
        return lhs.id == rhs.id
    }
}

extension AnyWebsite {
    public struct Raw {
        public var title: Optional<String?>
        public var originalURL: Optional<URL?>
        public var resolvedURL: Optional<URL?>
        public var isArchived: Optional<Bool>
        public var thumbnail: Optional<Data?>
        
        public init(title: Optional<String?> = nil,
                    originalURL: Optional<URL?> = nil,
                    resolvedURL: Optional<URL?> = nil,
                    isArchived: Optional<Bool> = nil,
                    thumbnail: Optional<Data?> = nil)
        {
            self.title = title
            self.originalURL = originalURL
            self.resolvedURL = resolvedURL
            self.isArchived = isArchived
            self.thumbnail = thumbnail
        }
    }
}
