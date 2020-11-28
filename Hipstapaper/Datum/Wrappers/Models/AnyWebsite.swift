//
//  Created by Jeffrey Bergier on 2020/11/27.
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

import Combine

public struct AnyWebsite: Website {

    public typealias ID = ObjectIdentifier

    public var id:          ID      { _id() }
    public var isArchived:  Bool    { _isArchived() }
    public var originalURL: URL?    { _originalURL() }
    public var resolvedURL: URL?    { _resolvedURL() }
    public var title:       String? { _title() }
    public var thumbnail:   Data?   { _thumbnail() }
    public var dateCreated: Date    { _dateCreated() }
    public var dateModified: Date   { _dateModified() }

    private let _id:           () -> ID
    private let _isArchived:   () -> Bool
    private let _originalURL:  () -> URL?
    private let _resolvedURL:  () -> URL?
    private let _title:        () -> String?
    private let _thumbnail:    () -> Data?
    private var _dateCreated:  () -> Date
    private var _dateModified: () -> Date

    /// Untyped storage for original database object
    internal let wrappedValue: Any

    internal init<T: Website>(_ website: T) where T.ID == ID {
        _id = { website.id }
        _isArchived   = { website.isArchived }
        _originalURL  = { website.originalURL }
        _resolvedURL  = { website.resolvedURL }
        _title        = { website.title }
        _thumbnail    = { website.thumbnail }
        _dateCreated  = { website.dateCreated }
        _dateModified = { website.dateModified }
        wrappedValue  = website
    }
}
