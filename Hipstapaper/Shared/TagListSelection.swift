//
//  Created by Jeffrey Bergier on 2020/12/01.
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

import Datum

struct TagListSelection {
    var query = Query(isArchived: .all, tag: nil, search: nil)
    var raw: AnyTag? = nil {
        didSet {
            self.query.search = nil
            self.query.tag = nil
            guard let tag = self.raw else { return }
            if let fakeTag = tag.wrappedValue as? Query.Archived {
                self.query.isArchived = fakeTag
            } else {
                self.query.tag = tag
            }
        }
    }
}

extension Query.Archived {
    static var tagCases: [AnyTag] {
        return allCases.map { AnyTag($0) }
    }
}

extension Query.Archived: Tag {
    public var name: String? {
        switch self {
        case .unarchived:
            return "Unarchived Items"
        case .all:
            return "All Items"
        }
    }
    
    public var websitesCount: Int { return -1 }
    public var dateCreated: Date { fatalError() }
    public var dateModified: Date { fatalError() }
}
