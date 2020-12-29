//
//  Created by Jeffrey Bergier on 2020/12/21.
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
import Stylize
import Localize

func ButtonToolbarStopReload(isLoading: Bool,
                             stopAction: @escaping () -> Void,
                             reloadAction: @escaping () -> Void) -> some View
{
    return isLoading
        ? ButtonToolbar(systemName: "xmark",
                        accessibilityLabel: "Stop",
                        action: stopAction)
        .keyboardShortcut(".")
        .disabled(!isLoading)
        : ButtonToolbar(systemName: "arrow.clockwise",
                        accessibilityLabel: "Reload",
                        action: reloadAction)
        .keyboardShortcut("r")
        .disabled(isLoading)
}

func ButtonToolbarJavascript(isJSEnabled: Bool, toggleAction: @escaping () -> Void) -> some View {
    let icon = isJSEnabled ? "applescript.fill" : "applescript"
    let label: LocalizedStringKey = isJSEnabled ? "Disable Javascript" : "Enable Javascript"
    return ButtonToolbar(systemName: icon, accessibilityLabel: label, action: toggleAction)
}
