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
import Localize
    
/// Normal button
public func ButtonDefault(_ label: LocalizedStringKey,
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
public func ButtonDone(_ label: LocalizedStringKey,
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

public struct ButtonToolbar: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isEnabled) var isEnabled
    private var systemName: String
    private var accessibilityLabel: LocalizedStringKey
    private var action: () -> Void
    public var body: some View {
        Button(action: self.action) {
            Image(systemName: self.systemName)
                .foregroundColor(self.colorScheme.isNormal
                                    ? Color.toolbarIcon
                                    : Color.toolbarIcon_Dark)
                .opacity(self.isEnabled ? 1.0 : 0.5 )
        }
        .accessibility(label: Text(self.accessibilityLabel))
    }
    public init(systemName: String,
                accessibilityLabel: LocalizedStringKey,
                action: @escaping () -> Void)
    {
        self.systemName = systemName
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }
}

public func ButtonToolbarShare(_ action: @escaping () -> Void) -> some View {
    ButtonToolbar(systemName: "square.and.arrow.up",
                  accessibilityLabel: Verb.Share,
                  action: action)
}

public func ButtonToolbarBrowserInApp(_ action: @escaping () -> Void) -> some View {
    ButtonToolbar(systemName: "safari",
                  accessibilityLabel: Verb.Open,
                  action: action)
}

public func ButtonToolbarBrowserExternal(_ action: @escaping () -> Void) -> some View {
    ButtonToolbar(systemName: "safari.fill",
                  accessibilityLabel: Verb.Safari,
                  action: action)
}
