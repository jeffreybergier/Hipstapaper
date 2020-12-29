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
import Combine

@objc(CD_Base) internal class CD_Base: NSManagedObject, Identifiable {

    /// Template for fetch request in subclasses
    internal class var entityName: String { "CD_Base" }
    private class var request: NSFetchRequest<CD_Base> {
        NSFetchRequest<CD_Base>(entityName: self.entityName)
    }

    @NSManaged internal var cd_dateCreated: Date
    @NSManaged internal var cd_dateModified: Date

    override internal func awakeFromInsert() {
        super.awakeFromInsert()
        let date = Date()
        self.cd_dateModified = date
        self.cd_dateCreated = date
    }

    /// Override to validate your properties before saving
    internal func datum_willSave() {
        self.cd_dateModified = Date()
    }
}
