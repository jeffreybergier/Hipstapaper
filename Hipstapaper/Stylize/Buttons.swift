//
//  Created by Jeffrey Bergier on 2020/12/11.
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

extension Button where Label == Text {
    
    /// Normal button
    public static func Default(_ label: LocalizedStringKey,
                               action: @escaping () -> Void) -> some View
    {
        let b = Button(action: action) {
            Text(label)
                .font(.subheadline)
        }
        #if canImport(AppKit)
        return b.buttonStyle(BorderedButtonStyle())
        #else
        return b
        #endif
    }
    
    /// Button with more prominence.
    public static func Done(_ label: LocalizedStringKey,
                            action: @escaping () -> Void) -> some View
    {
        let b = Button(action: action) {
            Text(label)
                .font(.headline)
        }
        #if canImport(AppKit)
        return b.buttonStyle(BorderedButtonStyle())
        #else
        return b
        #endif
    }
}

extension Button where Label == Image {
    
    public static func ToolbarIcon(systemName: String,
                                   accessibilityLabel: LocalizedStringKey,
                                   action: @escaping () -> Void) -> some View
    {
        return Button(action: action, label: { Image(systemName: systemName) })
            .accessibility(label: Text(accessibilityLabel))
    }
}
