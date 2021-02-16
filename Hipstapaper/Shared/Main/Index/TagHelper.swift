//
//  Created by Jeffrey Bergier on 2021/02/06.
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


import SwiftUI
import Umbrella
import Datum

typealias TH = TagHelper

enum TagHelper {
    
    typealias Selection = AnyElementObserver<AnyTag>
    
    static func canDelete(_ selection: Selection?) -> Bool {
        guard let tag = selection else { return false }
        return tag.canDelete
    }
    static func delete(_ selection: Selection?, _ controller: Controller, _ errorQ: ErrorQ) {
        guard let tag = selection else { return }
        let r = errorQ.append(controller.delete(tag))
        log.error(r.error)
    }
}
