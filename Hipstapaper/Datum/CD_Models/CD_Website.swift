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

extension CD_Website: Website {
    var isArchived: Bool { cd_isArchived }
    var originalURL: URL? { cd_originalURL }
    var resolvedURL: URL? { cd_resolvedURL }
    var title: String? { cd_title }
    var thumbnail: Data? { cd_thumbnail }
}

@objc(CD_Website) internal class CD_Website: CD_Base {

    internal class override var entityName: String { "CD_Website" }
    internal class var request: NSFetchRequest<CD_Website> {
        NSFetchRequest<CD_Website>(entityName: self.entityName)
    }

    @NSManaged internal var cd_isArchived:  Bool
    @NSManaged internal var cd_originalURL: URL?
    @NSManaged internal var cd_resolvedURL: URL?
    @NSManaged internal var cd_title:       String?
    @NSManaged internal var cd_thumbnail:   Data?
    @NSManaged internal var cd_tags:        NSSet

    internal override func datum_willSave() {
        super.datum_willSave()

        // validate title

        // validate thumbnail size
    }
}


