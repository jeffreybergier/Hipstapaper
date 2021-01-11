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

public protocol Buttonable {
    static var icon: String? { get }
    static var phrase: LocalizedStringKey { get }
    static var verb: LocalizedStringKey { get }
    static var shortcut: KeyboardShortcut? { get }
}

extension Buttonable {
    public static func button(isDisabled: Bool = false, action: @escaping Action) -> some View {
        return Button(action: action) { () -> AnyView in
            if let icon = self.icon {
                return AnyView(Label(self.verb, systemImage: icon))
            } else {
                return AnyView(Text(self.verb))
            }
        }
        .disabled(isDisabled)
        .help(self.phrase)
        .modifier(Shortcut(self.shortcut))
    }
}

internal struct Shortcut: ViewModifier {
    internal var shortcut: KeyboardShortcut?
    internal init(_ shortcut: KeyboardShortcut?) {
        self.shortcut = shortcut
    }
    internal func body(content: Content) -> some View {
        if let shortcut = self.shortcut {
            return AnyView(content.keyboardShortcut(shortcut))
        } else {
            return AnyView(content)
        }
    }
}

extension STZ {
    public enum BTN {
        
    }
}
