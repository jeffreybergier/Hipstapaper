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
    return Button(action: action) {
        Text(label)
            .font(.subheadline)
    }
    .modifier(STZ_BorderedButtonStyle())
}

/// Button with more prominence.
public func ButtonDone(_ label: LocalizedStringKey,
                       action: @escaping () -> Void) -> some View
{
    return Button(action: action) {
        Text(label)
            .font(.headline)
    }
    .modifier(STZ_BorderedButtonStyle())
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
        .help(self.accessibilityLabel)
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

public func ButtonToolbarSeparator() -> some View {
    Button(action: {}) {
        Text("|")
    }
    .buttonStyle(BorderlessButtonStyle())
    .disabled(true)
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

public func ButtonToolbarFilterA(_ action: @escaping () -> Void) -> ButtonToolbar {
    ButtonToolbar(systemName: "line.horizontal.3.decrease.circle.fill",
                  accessibilityLabel: Phrase.FilterA,
                  action: action)
}

public func ButtonToolbarFilterB(_ action: @escaping () -> Void) -> ButtonToolbar {
    ButtonToolbar(systemName: "line.horizontal.3.decrease.circle",
                  accessibilityLabel: Phrase.FilterB,
                  action: action)
}

public func ButtonToolbarSort(_ action: @escaping () -> Void) -> ButtonToolbar {
    ButtonToolbar(systemName: "arrow.up.arrow.down.circle",
                  accessibilityLabel: Phrase.Sort,
                  action: action)
}

public func ButtonToolbarStopReload(isLoading: Bool,
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

public struct ButtonToolbarJavascript: View {
    @Binding private var isJSEnabled: Bool
    public var body: some View {
        __ButtonToolbarJavascript(isJSEnabled: self.isJSEnabled,
                                  toggleAction: { self.isJSEnabled.toggle() })
    }
    public init(_ isJSEnabled: Binding<Bool>) {
        _isJSEnabled = isJSEnabled
    }
}

private func __ButtonToolbarJavascript(isJSEnabled: Bool, toggleAction: @escaping () -> Void) -> some View {
    let icon = isJSEnabled ? "applescript.fill" : "applescript"
    let label: LocalizedStringKey = isJSEnabled ? "Disable Javascript" : "Enable Javascript"
    return ButtonToolbar(systemName: icon,
                         accessibilityLabel: label,
                         action: toggleAction)
        .modifier(STZ_BorderedButtonStyle())
}

public struct STZ_BorderedButtonStyle: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        #if os(macOS)
        return content.buttonStyle(BorderedButtonStyle())
        #else
        return content
        #endif
    }
}
