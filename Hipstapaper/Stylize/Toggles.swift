//
//  Created by Jeffrey Bergier on 2020/12/14.
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

internal func _ToggleDefault(label: TextProvider, isOn: Binding<Bool>) -> some View {
    return Toggle(isOn: isOn, label: { () -> AnyView in
        switch label {
        case .localized(let title):
            return AnyView(Text.IndexRowTitleDisabled(title))
        case .raw(let title):
            return AnyView(Text.IndexRowTitle(title))
        }
    })
    //.toggleStyle(SwitchToggleStyle())
}

public func ToggleDefault(label: String?, isOn: Binding<Bool>) -> some View {
    let provider: TextProvider
    if let label = label {
        provider = .raw(label)
    } else {
        provider = .localized(Untitled)
    }
    return _ToggleDefault(label: provider, isOn: isOn)
}
