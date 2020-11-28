//
//  Created by Jeffrey Bergier on 2020/11/26.
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

public struct AnyTag: Tag {

    public typealias ID = ObjectIdentifier

    public var id: ID             { _id() }
    public var name: String?      { _name() }
    public var websitesCount: Int { _websitesCount() }
    public var dateCreated: Date  { _dateCreated() }
    public var dateModified: Date { _dateModified() }

    private var _id:            () -> ID
    private var _name:          () -> String?
    private var _websitesCount: () -> Int
    private var _dateCreated:   () -> Date
    private var _dateModified:  () -> Date

    internal let wrappedValue: Any

    internal init<T: Tag>(_ tag: T) where T.ID == ID {
        _id            = { tag.id }
        _name          = { tag.name }
        _websitesCount = { tag.websitesCount }
        _dateCreated   = { tag.dateCreated }
        _dateModified  = { tag.dateModified }
        wrappedValue   = tag
    }
}
