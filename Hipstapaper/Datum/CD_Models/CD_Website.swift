//
//  Created by Jeffrey Bergier on 2020/11/23.
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

import CoreData

public typealias Website = CD_Website
@objc public class CD_Website: CD_Base {

    internal class override var entityName: String { "CD_Website" }
    internal class var request: NSFetchRequest<CD_Website> {
        NSFetchRequest<CD_Website>(entityName: self.entityName)
    }

    @NSManaged public internal(set) var isArchived: Bool
    @NSManaged public internal(set) var originalURL: URL?
    @NSManaged public internal(set) var resolvedURL: URL?
    @NSManaged public internal(set) var title: URL?
    @NSManaged public internal(set) var thumbnail: Data?
    @NSManaged public internal(set) var tags: NSSet?

    internal override func performPropertyValidation() {
        super.performPropertyValidation()

        // validate title

        // validate thumbnail size
    }
}
