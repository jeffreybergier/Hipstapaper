//
//  Created by Jeffrey Bergier on 2021/02/23.
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
    /// Icon in label or toolbar
    static var icon: STZ.ICN? { get }
    /// Action / Title / Label / Button Text
    static var verb: Verb { get }
}

public protocol Buttonable: Labelable {
    /// Tooltip / Accessibility
    static var phrase: Phrase { get }
    /// Keyboard shortcut
    static var shortcut: KeyboardShortcut? { get }
}

public typealias Toolbarable = Buttonable

public protocol Presentable: Buttonable {
    /// Title of presented view
    static var noun: Noun { get }
}

extension Labelable {
    @ViewBuilder public static func label() -> some View {
        if let icon = self.icon {
            Label(self.verb.rawValue, systemImage: icon.rawValue)
                .modifier(STZ.FNT.Sort.apply())
        } else {
            STZ.VIEW.TXT(self.verb.rawValue)
                .modifier(STZ.FNT.Sort.apply())
        }
    }
}

extension Buttonable {
    public static func button(doneStyle: Bool = false,
                              isEnabled: Bool = true,
                              action: @escaping Action) -> some View
    {
        self.context(doneStyle: doneStyle,
                     isEnabled: isEnabled,
                     action: action)
            .modifier(DefaultButtonStyle()) // if this modifier is used on context menu buttons everything breaks
    }
    
    public static func context(doneStyle: Bool = false,
                               isEnabled: Bool = true,
                               action: @escaping Action)
                               -> some View
    {
        Button(action: action) {
            self.label()
                .modifier(DoneStyle(enabled: doneStyle))
        }
        .disabled(!isEnabled)
        .help(self.phrase.rawValue)
        .modifier(Shortcut(self.shortcut))
    }
}

extension Toolbarable {
    public static func toolbar(isEnabled: Bool = true, action: @escaping Action) -> some View {
        return Button(action: action) {
            self.label()
                .modifier(__Hack_ToolbarButtonStyle())
        }
        .disabled(!isEnabled)
        .help(self.phrase.rawValue)
        .modifier(Shortcut(self.shortcut))
    }
    
    public static func __fake_macOS_toolbar(isEnabled: Bool = true, action: @escaping Action) -> some View {
        #if os(macOS)
        return Button(action: action) {
            self.icon!
                .modifier(__Hack_ToolbarButtonStyle())
        }
        .disabled(!isEnabled)
        .help(self.phrase.rawValue)
        .modifier(Shortcut(self.shortcut))
        #else
        return self.toolbar(isEnabled: isEnabled, action: action)
        #endif
    }
}
