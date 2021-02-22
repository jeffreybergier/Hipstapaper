//
//  Created by Jeffrey Bergier on 2020/11/24.
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

extension CD_Tag: Tag {
    var name: String? { cd_name }
    var websitesCount: Int? { Int(self.cd_websitesCount) }
}

@objc(CD_Tag) internal class CD_Tag: CD_Base {

    internal class override var entityName: String { "CD_Tag" }
    internal class var request: NSFetchRequest<CD_Tag> {
        NSFetchRequest<CD_Tag>(entityName: self.entityName)
    }

    @NSManaged internal var cd_websitesCount: Int32
    @NSManaged internal var cd_name: String?
    @NSManaged internal var cd_websites: NSSet
    
    override func willSave() {
        super.willSave()
        let newWebsitesCount = Int32(self.cd_websites.count)
        if self.cd_websitesCount != newWebsitesCount {
            self.cd_websitesCount = newWebsitesCount
        }
        
        // Validate Title
        if let name = self.cd_name, name.trimmed == nil {
            self.cd_name = nil
        }
    }
}

