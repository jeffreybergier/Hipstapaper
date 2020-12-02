//
//  Created by Jeffrey Bergier on 2020/12/02.
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

extension Query.Archived: Tag {
    
    // TODO: See if its possible change type to LocalizedString
    public var localizedDescription: String {
        switch self {
        case .all:
            return "All Items"
        case .unarchived:
            return "Unread Items"
        }
    }
    
    public var name: String? { self.localizedDescription }
    public var websitesCount: Int? { return nil }
    public var dateCreated: Date { fatalError() }
    public var dateModified: Date { fatalError() }
}
