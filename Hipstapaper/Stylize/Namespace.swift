//
//  Created by Jeffrey Bergier on 2021/01/11.
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

public enum STZ {}
public typealias Action = () -> Void

public protocol Labelable {
    /// Icon in label or toolbar
    static var icon: STZ.ICN? { get }
    /// Action / Title / Label / Button Text
    static var verb: Verb { get }
}

public protocol Buttonable {
    /// Icon in label or toolbar
    static var icon: STZ.ICN? { get }
    /// Tooltip / Accessibility
    static var phrase: Phrase { get }
    /// Button title / Toolbar text
    static var verb: Verb { get }
    /// Keyboard shortcut
    static var shortcut: KeyboardShortcut? { get }
}

extension Labelable {
    @ViewBuilder public static func label() -> some View {
        if let icon = self.icon {
            Label(self.noun.rawValue, systemImage: icon.rawValue)
                .modifier(STZ.FNT.Sort.apply())
        } else {
            Text(self.noun.rawValue)
                .modifier(STZ.FNT.Sort.apply())
        }
    }
}
