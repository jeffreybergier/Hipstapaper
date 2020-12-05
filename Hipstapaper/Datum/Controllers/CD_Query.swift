//
//  Created by Jeffrey Bergier on 2020/11/28.
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

extension Query {
    internal var cd_sortDescriptors: [NSSortDescriptor] { self.sort.cd_sortDescriptors }
    internal var cd_predicate: NSPredicate? {
        let predicates: [NSPredicate] = [
            {
                guard case .unarchived = self.isArchived else { return nil }
                return NSPredicate(format: "%K == NO", #keyPath(CD_Website.isArchived))
            }(),
            {
                guard let search = self.search.nonEmptyString else { return nil }
                return NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(CD_Website.title), search),
                    NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(CD_Website.resolvedURL), search),
                    NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(CD_Website.originalURL), search),
                ])
            }(),
            {
                guard let _tag = self.tag else { return nil }
                guard let tag = _tag.wrappedValue as? CD_Tag
                else { assertionFailure("Invalid TAG Object"); return nil; }
                return NSPredicate(format: "%K CONTAINS %@", #keyPath(CD_Website.tags), tag)
            }(),
        ].compactMap { $0 }
        guard predicates.isEmpty == false else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
