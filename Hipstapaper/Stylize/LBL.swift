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

public protocol Labelable {
    static var icon: String { get }
    static var text: LocalizedStringKey { get }
}

extension Labelable {
    public static func label() -> some View {
        Label(self.text, systemImage: self.icon)
            .modifier(STZ.FNT.Sort.apply())
    }
}

extension STZ {
    public enum LBL {
        public enum Sort {
            
        }
    }
}

extension STZ.LBL.Sort {
    public enum TitleA: Labelable {
        public static let icon = "doc.richtext"
        public static let text = Phrase.sortTitleA.rawValue
    }
    public enum TitleZ: Labelable {
        public static let icon = "doc.richtext.fill"
        public static let text = Phrase.sortTitleZ.rawValue
    }
    public enum ModifiedNewest: Labelable {
        public static let icon = "calendar.circle"
        public static let text = Phrase.sortDateModifiedNewest.rawValue
    }
    public enum ModifiedOldest: Labelable {
        public static let icon = "calendar.circle.fill"
        public static let text = Phrase.sortDateModifiedOldest.rawValue
    }
    public enum CreatedNewest: Labelable {
        public static let icon = "calendar.circle"
        public static let text = Phrase.sortDateCreatedNewest.rawValue
    }
    public enum CreatedOldest: Labelable {
        public static let icon = "calendar.circle.fill"
        public static let text = Phrase.sortDateCreatedOldest.rawValue
    }
}
