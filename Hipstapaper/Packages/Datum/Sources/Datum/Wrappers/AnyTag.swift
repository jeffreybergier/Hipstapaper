//
//  Created by Jeffrey Bergier on 2020/11/26.
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
import Combine

public struct AnyTag: Tag {

    public typealias ID = ObjectIdentifier

    public var id: ID              { _id() }
    public var uri: URL            { _uri() }
    public var name: String?       { _name() }
    public var websitesCount: Int? { _websitesCount() }
    public var dateCreated: Date   { _dateCreated() }
    public var dateModified: Date  { _dateModified() }
    public func hash(into hasher: inout Hasher) { _hashValue(&hasher) }

    private var _id:            () -> ID
    private var _uri:           () -> URL
    private var _name:          () -> String?
    private var _websitesCount: () -> Int?
    private var _dateCreated:   () -> Date
    private var _dateModified:  () -> Date
    private var _hashValue:     (inout Hasher) -> ()

    internal let wrappedValue: Any

    public init<T: Tag>(_ tag: T) where T.ID == ID {
        _id            = { tag.id }
        _uri           = { tag.uri }
        _name          = { tag.name }
        _websitesCount = { tag.websitesCount }
        _dateCreated   = { tag.dateCreated }
        _dateModified  = { tag.dateModified }
        _hashValue     = tag.hash
        wrappedValue   = tag
    }
    
    public static func == (lhs: AnyTag, rhs: AnyTag) -> Bool {
        return lhs.id == rhs.id
    }
}
