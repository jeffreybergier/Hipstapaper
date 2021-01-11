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

public protocol Toolbarable {
    static var icon: String { get }
    static var phrase: LocalizedStringKey { get }
    static var verb: LocalizedStringKey { get }
    static var noun: LocalizedStringKey { get }
    static var shortcut: KeyboardShortcut { get }
}

fileprivate struct __Hack_ToolbarButtonStyle: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(self.colorScheme.isNormal
                                ? Color.toolbarIcon
                                : Color.toolbarIcon_Dark)
            .opacity(self.isEnabled ? 1.0 : 0.5 )
    }
}

extension Toolbarable {
    public static func toolbarButton(isDisabled: Bool = false, action: @escaping Action) -> some View {
        return Button(action: action) {
            Image(systemName: self.icon)
        }
        .keyboardShortcut(self.shortcut)
        .modifier(__Hack_ToolbarButtonStyle())
        .disabled(isDisabled)
        .help(self.phrase)
    }
    
    public static func contextButton(isDisabled: Bool, action: @escaping Action) -> some View {
        return Button(action: action) {
            Label(self.verb, systemImage: self.icon)
        }
        .keyboardShortcut(self.shortcut)
        .disabled(isDisabled)
        .help(self.phrase)
    }
}

extension STZ {
    public enum TB {
        public enum TagApply: Toolbarable {
            public static let icon: String = "tag"
            public static let phrase: LocalizedStringKey = Verb.AddAndRemoveTags
            public static let verb: LocalizedStringKey = Verb.AddAndRemoveTags
            public static let noun: LocalizedStringKey = Noun.ApplyTags
            public static let shortcut: KeyboardShortcut = .init("t", modifiers: [.command, .shift])
        }
        public enum Share: Toolbarable {
            public static let icon: String = "square.and.arrow.up"
            public static let phrase: LocalizedStringKey = Verb.Share
            public static let verb: LocalizedStringKey = Verb.Share
            public static let noun: LocalizedStringKey = Verb.Share
            public static let shortcut: KeyboardShortcut = .init("i", modifiers: [.command, .shift])
        }
        public enum SearchInactive: Toolbarable {
            public static let icon: String = "magnifyingglass"
            public static let phrase: LocalizedStringKey = Verb.Search
            public static let verb: LocalizedStringKey = Verb.Search
            public static let noun: LocalizedStringKey = Noun.Search
            public static let shortcut: KeyboardShortcut = .init("f", modifiers: [.command])
        }
        public enum SearchActive: Toolbarable {
            public static let icon: String = "magnifyingglass.circle.fill"
            public static let phrase: LocalizedStringKey = Verb.Search
            public static let verb: LocalizedStringKey = Verb.Search
            public static let noun: LocalizedStringKey = Noun.Search
            public static let shortcut: KeyboardShortcut = .init("f", modifiers: [.command])
        }
        public enum Unarchive: Toolbarable {
            public static let icon: String = "tray.and.arrow.up"
            public static let phrase: LocalizedStringKey = Verb.Unarchive
            public static let verb: LocalizedStringKey = Verb.Unarchive
            public static let noun: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut = .init("u", modifiers: [.command, .control])
        }
        public enum Archive: Toolbarable {
            public static let icon: String = "tray.and.arrow.down"
            public static let phrase: LocalizedStringKey = Verb.Archive
            public static let verb: LocalizedStringKey = Verb.Archive
            public static let noun: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut = .init("a", modifiers: [.command, .control])
        }
        public enum OpenInBrowser: Toolbarable {
            public static let icon: String = "safari.fill"
            public static let phrase: LocalizedStringKey = Verb.Safari
            public static let verb: LocalizedStringKey = Verb.Safari
            public static let noun: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut = .init("o", modifiers: [.command, .shift])
        }
        public enum OpenInApp: Toolbarable {
            public static let icon: String = "safari"
            public static let phrase: LocalizedStringKey = Verb.Open
            public static let verb: LocalizedStringKey = Verb.Open
            public static let noun: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut = .init("o", modifiers: [.command])
        }
        public enum FilterActive: Toolbarable {
            public static let icon: String = "line.horizontal.3.decrease.circle.fill"
            public static let phrase: LocalizedStringKey = Phrase.FilterA
            public static let verb: LocalizedStringKey = { fatalError() }()
            public static let noun: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut = .init("l", modifiers: [.command, .shift])
        }
        public enum FilterInactive: Toolbarable {
            public static let icon: String = "line.horizontal.3.decrease.circle"
            public static let phrase: LocalizedStringKey = Phrase.FilterB
            public static let verb: LocalizedStringKey = { fatalError() }()
            public static let noun: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut = .init("l", modifiers: [.command, .shift])
        }
        public enum Sort: Toolbarable {
            public static let icon: String = "arrow.up.arrow.down.circle"
            public static let phrase: LocalizedStringKey = Phrase.Sort
            public static let verb: LocalizedStringKey = Phrase.Sort
            public static let noun: LocalizedStringKey = Noun.Sort
            public static let shortcut: KeyboardShortcut = .init("`", modifiers: [.command, .option])
        }
        
        // MARK: Weird Buttons
        public enum Separator {
            public static func toolbarButton() -> some View {
                Button(action: {}) {
                    Text("|")
                }
                .buttonStyle(BorderlessButtonStyle())
                .disabled(true)
            }
        }
    }
}
