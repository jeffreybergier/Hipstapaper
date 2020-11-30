//
//  Created by Jeffrey Bergier on 2020/11/30.
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

import Foundation

extension Sort {
    internal var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .dateModifiedNewest:
            return [.init(key: #keyPath(CD_Website.dateModified), ascending: true)]
        case .dateModifiedOldest:
            return [.init(key: #keyPath(CD_Website.dateModified), ascending: false)]
        case .dateCreatedNewest:
            return [.init(key: #keyPath(CD_Website.dateCreated), ascending: true)]
        case .dateCreatedOldest:
            return [.init(key: #keyPath(CD_Website.dateCreated), ascending: false)]
        case .titleA:
            return [.init(key: #keyPath(CD_Website.title), ascending: true)]
        case .titleZ:
            return [.init(key: #keyPath(CD_Website.title), ascending: false)]
        }
    }
}