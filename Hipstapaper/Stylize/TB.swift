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

public typealias Toolbarable = Buttonable

extension Toolbarable {
    public static func toolbar(isEnabled: Bool = true, action: @escaping Action) -> some View {
        return Button(action: action) {
            (self.icon ?? STZ.ICN.bug)
                .modifier(__Hack_ToolbarButtonStyle())
        }
        .disabled(!isEnabled)
        .help(self.phrase)
        .modifier(Shortcut(self.shortcut))
    }
}

fileprivate struct __Hack_ToolbarButtonStyle: ViewModifier {
    
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        #if os(macOS)
        return content
            .modifier(STZ.CLR.TB.Tint.foreground())
            .opacity(self.isEnabled ? 1.0 : 0.5 )
        #else
        return content
        #endif
    }
}

extension STZ {
    public enum TB {
        public enum Share: Toolbarable {
            public static let icon: STZ.ICN? = .share
            public static let phrase: LocalizedStringKey = Verb.Share
            public static let verb: LocalizedStringKey = Verb.Share
            public static let shortcut: KeyboardShortcut? = .init("i", modifiers: [.command, .shift])
        }
        public enum Unarchive: Toolbarable {
            public static let icon: STZ.ICN? = .unarchive
            public static let phrase: LocalizedStringKey = Verb.Unarchive
            public static let verb: LocalizedStringKey = Verb.Unarchive
            public static let shortcut: KeyboardShortcut? = .init("u", modifiers: [.command, .control])
        }
        public enum Archive: Toolbarable {
            public static let icon: STZ.ICN? = .archive
            public static let phrase: LocalizedStringKey = Verb.Archive
            public static let verb: LocalizedStringKey = Verb.Archive
            public static let shortcut: KeyboardShortcut? = .init("a", modifiers: [.command, .control])
        }
        public enum OpenInBrowser: Toolbarable {
            public static let icon: STZ.ICN? = .openInBrowser
            public static let phrase: LocalizedStringKey = Verb.Safari
            public static let verb: LocalizedStringKey = Verb.Safari
            public static let shortcut: KeyboardShortcut? = .init("o", modifiers: [.command, .shift])
        }
        public enum OpenInApp: Toolbarable {
            public static let icon: STZ.ICN? = .openInApp
            public static let phrase: LocalizedStringKey = Verb.Open
            public static let verb: LocalizedStringKey = Verb.Open
            public static let shortcut: KeyboardShortcut? = .init("o", modifiers: [.command])
        }
        public enum FilterActive: Toolbarable {
            public static let icon: STZ.ICN? = .filterActive
            public static let phrase: LocalizedStringKey = Phrase.FilterA
            public static let verb: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut? = .init("l", modifiers: [.command, .shift])
        }
        public enum FilterInactive: Toolbarable {
            public static let icon: STZ.ICN? = .filterInactive
            public static let phrase: LocalizedStringKey = Phrase.FilterB
            public static let verb: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut? = .init("l", modifiers: [.command, .shift])
        }
        public enum Stop: Toolbarable {
            public static let icon: STZ.ICN? = .stop
            public static let phrase: LocalizedStringKey = "Stop"
            public static let verb: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut? = .init(".", modifiers: [.command])
        }
        public enum Reload: Toolbarable {
            public static let icon: STZ.ICN? = .reload
            public static let phrase: LocalizedStringKey = "Reload"
            public static let verb: LocalizedStringKey = { fatalError() }()
            public static let shortcut: KeyboardShortcut? = .init("r", modifiers: [.command])
        }
        public enum JSActive: Toolbarable {
            public static let icon: STZ.ICN? = .jsActive
            public static let phrase: LocalizedStringKey = "Disable Javascript"
            public static let verb: LocalizedStringKey = "Javascript"
            public static let shortcut: KeyboardShortcut? = .init("j", modifiers: [.command, .option])
        }
        public enum JSInactive: Toolbarable {
            public static let icon: STZ.ICN? = .jsInactive
            public static let phrase: LocalizedStringKey = "Enable Javascript"
            public static let verb: LocalizedStringKey = "Javascript"
            public static let shortcut: KeyboardShortcut? = .init("j", modifiers: [.command, .option])
        }
        public enum GoBack: Toolbarable {
            public static let icon: STZ.ICN? = .goBack
            public static let phrase: LocalizedStringKey = "Show the previous page"
            public static let verb: LocalizedStringKey = "Back"
            public static let shortcut: KeyboardShortcut? = .init("[", modifiers: [.command])
        }
        public enum GoForward: Toolbarable {
            public static let icon: STZ.ICN? = .goForward
            public static let phrase: LocalizedStringKey = "Show the next page"
            public static let verb: LocalizedStringKey = "Forward"
            public static let shortcut: KeyboardShortcut? = .init("]", modifiers: [.command])
        }
        public enum DeleteTag_Minus: Toolbarable {
            public static let icon: STZ.ICN? = .deleteMinus
            public static let phrase: LocalizedStringKey = Verb.DeleteTag
            public static let verb: LocalizedStringKey = Verb.DeleteTag
            public static let shortcut: KeyboardShortcut? = .init(.delete, modifiers: [.command])
        }
        public enum DeleteWebsite: Toolbarable {
            public static let icon: STZ.ICN? = .deleteTrash
            public static let phrase: LocalizedStringKey = "Delete website"
            public static let verb: LocalizedStringKey = "Delete Website"
            public static let shortcut: KeyboardShortcut? = .init(.delete, modifiers: [.command])
        }
        public enum DeleteTag_Trash: Toolbarable {
            public static let icon: STZ.ICN? = .deleteTrash
            public static let phrase: LocalizedStringKey = "Delete tag"
            public static let verb: LocalizedStringKey = "Delete Tag"
            public static let shortcut: KeyboardShortcut? = .init(.delete, modifiers: [.command])
        }
        public enum ClearSearch: Toolbarable {
            public static let icon: STZ.ICN? = .clearSearch
            public static let phrase: LocalizedStringKey = Verb.ClearSearch
            public static let verb: LocalizedStringKey = Verb.ClearSearch
            public static let shortcut: KeyboardShortcut? = .init(.escape, modifiers: [])
        }
        public enum CloudSyncError: Toolbarable {
            public static let icon: STZ.ICN? = .cloudError
            public static let phrase: LocalizedStringKey = "iCloud Sync Error"
            public static let verb: LocalizedStringKey = "iCloud Sync Error"
            public static let shortcut: KeyboardShortcut? = nil
        }
        public enum CloudAccountError: Toolbarable {
            public static let icon: STZ.ICN? = .cloudAccountError
            public static let phrase: LocalizedStringKey = "No iCloud Account"
            public static let verb: LocalizedStringKey = "No iCloud Account"
            public static let shortcut: KeyboardShortcut? = nil
        }
        
        // MARK: Weird Buttons
        public enum Separator {
            public static func toolbar() -> some View {
                Button(action: {}) {
                    STZ.VIEW.TXT("|")
                }
                .buttonStyle(BorderlessButtonStyle())
                .disabled(true)
            }
        }
    }
}
