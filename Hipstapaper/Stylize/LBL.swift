//
//  Created by Jeffrey Bergier on 2021/01/16.
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
import Localize

extension STZ {
    public enum LBL {
        public enum Sort {
            public enum TitleA: Labelable {
                public static let icon: STZ.ICN? = .sortTitleA
                public static let verb: Verb = .sortTitleA
            }
            public enum TitleZ: Labelable {
                public static let icon: STZ.ICN? = .sortTitleZ
                public static let verb: Verb = .sortTitleZ
            }
            public enum ModifiedNewest: Labelable {
                public static let icon: STZ.ICN? = .sortDateNewest
                public static let verb: Verb = .sortDateModifiedNewest
            }
            public enum ModifiedOldest: Labelable {
                public static let icon: STZ.ICN? = .sortDateOldest
                public static let verb: Verb = .sortDateModifiedOldest
            }
            public enum CreatedNewest: Labelable {
                public static let icon: STZ.ICN? = .sortDateNewest
                public static let verb: Verb = .sortDateCreatedNewest
            }
            public enum CreatedOldest: Labelable {
                public static let icon: STZ.ICN? = .sortDateOldest
                public static let verb: Verb = .sortDateCreatedOldest
            }
        }
    }
}
