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

public protocol Buttonable {
    static var icon: STZ.ICN? { get }
    static var phrase: LocalizedStringKey { get }
    static var verb: LocalizedStringKey { get }
    static var shortcut: KeyboardShortcut? { get }
}

extension Buttonable {
    public static func button(doneStyle: Bool = false,
                              isEnabled: Bool = true,
                              action: @escaping Action) -> some View
    {
        context(doneStyle: doneStyle,
                isEnabled: isEnabled,
                action: action)
            .modifier(DefaultStyle()) // if this modifier is used on context menu buttons everything breaks
    }
    
    public static func context(doneStyle: Bool = false,
                               isEnabled: Bool = true,
                               action: @escaping Action)
                               -> some View
    {
        Button(action: action) {
            self.view()
                .modifier(DoneStyle(enabled: doneStyle))
        }
        .disabled(!isEnabled)
        .help(self.phrase)
        .modifier(Shortcut(self.shortcut))
    }
    
    @ViewBuilder public static func view() -> some View {
        if let icon = self.icon {
            Label(self.verb, systemImage: icon.rawValue)
        } else {
            STZ.VIEW.TXT(self.verb)
        }
    }
}

fileprivate struct DefaultStyle: ViewModifier {
    fileprivate func body(content: Content) -> some View {
        #if os(macOS)
        return content.buttonStyle(BorderedButtonStyle())
        #else
        return content
        #endif
    }
}

fileprivate struct DoneStyle: ViewModifier {
    var enabled: Bool
    func body(content: Content) -> some View {
        if enabled {
            return content
                .modifier(STZ.FNT.Button.Done.apply())
        } else {
            return content
                .modifier(STZ.FNT.Button.Default.apply())
        }
    }
}

internal struct Shortcut: ViewModifier {
    internal var shortcut: KeyboardShortcut?
    internal init(_ shortcut: KeyboardShortcut?) {
        self.shortcut = shortcut
    }
    @ViewBuilder internal func body(content: Content) -> some View {
        if let shortcut = self.shortcut {
            content.keyboardShortcut(shortcut)
        } else {
            content
        }
    }
}

extension STZ {
    public enum BTN {
        public enum Go: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: LocalizedStringKey = Verb.Go
            public static var verb: LocalizedStringKey = Verb.Go
            public static var shortcut: KeyboardShortcut? = .init(.defaultAction)
        }
        public enum Done: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: LocalizedStringKey = Verb.Done
            public static var verb: LocalizedStringKey = Verb.Done
            public static var shortcut: KeyboardShortcut? = .init(.defaultAction)
        }
        public enum BrowserDone: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: LocalizedStringKey = Verb.Done
            public static var verb: LocalizedStringKey = Verb.Done
            public static var shortcut: KeyboardShortcut? = .init("w")
        }
        public enum Save: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: LocalizedStringKey = Verb.Save
            public static var verb: LocalizedStringKey = Verb.Save
            public static var shortcut: KeyboardShortcut? = .init(.defaultAction)
        }
        public enum Cancel: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: LocalizedStringKey = Verb.Cancel
            public static var verb: LocalizedStringKey = Verb.Cancel
            public static var shortcut: KeyboardShortcut? = .init(.cancelAction)
        }
    }
}
