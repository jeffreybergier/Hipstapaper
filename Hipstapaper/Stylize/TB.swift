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
        .help(self.phrase.rawValue)
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
            public static let phrase: Phrase = .share
            public static let verb: Verb = .share
            public static let shortcut: KeyboardShortcut? = .init("i", modifiers: [.command, .shift])
        }
        public enum Unarchive: Toolbarable {
            public static let icon: STZ.ICN? = .unarchive
            public static let phrase: Phrase = .unarchive
            public static let verb: Verb = .unarchive
            public static let shortcut: KeyboardShortcut? = .init("u", modifiers: [.command, .control])
        }
        public enum Archive: Toolbarable {
            public static let icon: STZ.ICN? = .archive
            public static let phrase: Phrase = .archive
            public static let verb: Verb = .archive
            public static let shortcut: KeyboardShortcut? = .init("a", modifiers: [.command, .control])
        }
        public enum OpenInBrowser: Toolbarable {
            public static let icon: STZ.ICN? = .openInBrowser
            public static let phrase: Phrase = .safari
            public static let verb: Verb = .safari
            public static let shortcut: KeyboardShortcut? = .init("o", modifiers: [.command, .shift])
        }
        public enum OpenInApp: Toolbarable {
            public static let icon: STZ.ICN? = .openInApp
            public static let phrase: Phrase = .openInApp
            public static let verb: Verb = .openInApp
            public static let shortcut: KeyboardShortcut? = .init("o", modifiers: [.command])
        }
        public enum FilterActive: Toolbarable {
            public static let icon: STZ.ICN? = .filterActive
            public static let phrase: Phrase = .filterA
            public static let verb: Verb = .filter
            public static let shortcut: KeyboardShortcut? = .init("l", modifiers: [.command, .shift])
        }
        public enum FilterInactive: Toolbarable {
            public static let icon: STZ.ICN? = .filterInactive
            public static let phrase: Phrase = .filterB
            public static let verb: Verb = .filter
            public static let shortcut: KeyboardShortcut? = .init("l", modifiers: [.command, .shift])
        }
        public enum Stop: Toolbarable {
            public static let icon: STZ.ICN? = .stop
            public static let phrase: Phrase = .stopLoading
            public static let verb: Verb = .stopLoading
            public static let shortcut: KeyboardShortcut? = .init(".", modifiers: [.command])
        }
        public enum Reload: Toolbarable {
            public static let icon: STZ.ICN? = .reload
            public static let phrase: Phrase = .reloadPage
            public static let verb: Verb = .reloadPage
            public static let shortcut: KeyboardShortcut? = .init("r", modifiers: [.command])
        }
        public enum JSActive: Toolbarable {
            public static let icon: STZ.ICN? = .jsActive
            public static let phrase: Phrase = .jsActive
            public static let verb: Verb = .javascript
            public static let shortcut: KeyboardShortcut? = .init("j", modifiers: [.command, .option])
        }
        public enum JSInactive: Toolbarable {
            public static let icon: STZ.ICN? = .jsInactive
            public static let phrase: Phrase = .jsInactive
            public static let verb: Verb = .javascript
            public static let shortcut: KeyboardShortcut? = .init("j", modifiers: [.command, .option])
        }
        public enum GoBack: Toolbarable {
            public static let icon: STZ.ICN? = .goBack
            public static let phrase: Phrase = .goBack
            public static let verb: Verb = .goBack
            public static let shortcut: KeyboardShortcut? = .init("[", modifiers: [.command])
        }
        public enum GoForward: Toolbarable {
            public static let icon: STZ.ICN? = .goForward
            public static let phrase: Phrase = .goForward
            public static let verb: Verb = .goForward
            public static let shortcut: KeyboardShortcut? = .init("]", modifiers: [.command])
        }
        public enum DeleteTag_Minus: Toolbarable {
            public static let icon: STZ.ICN? = .deleteMinus
            public static let phrase: Phrase = .deleteTag
            public static let verb: Verb = .deleteTag
            public static let shortcut: KeyboardShortcut? = .init(.delete, modifiers: [.command])
        }
        public enum DeleteWebsite: Toolbarable {
            public static let icon: STZ.ICN? = .deleteTrash
            public static let phrase: Phrase = .deleteWebsite
            public static let verb: Verb = .deleteWebsite
            public static let shortcut: KeyboardShortcut? = .init(.delete, modifiers: [.command])
        }
        public enum DeleteTag_Trash: Toolbarable {
            public static let icon: STZ.ICN? = .deleteTrash
            public static let phrase: Phrase = .deleteTag
            public static let verb: Verb = .deleteTag
            public static let shortcut: KeyboardShortcut? = .init(.delete, modifiers: [.command])
        }
        public enum ClearSearch: Toolbarable {
            public static let icon: STZ.ICN? = .clearSearch
            public static let phrase: Phrase = .clearSearch
            public static let verb: Verb = .clearSearch
            public static let shortcut: KeyboardShortcut? = .init(.escape, modifiers: [])
        }
        public enum CloudSyncError: Toolbarable {
            public static let icon: STZ.ICN? = .cloudError
            public static let phrase: Phrase = .iCloudSyncError
            public static let verb: Verb = .iCloud
            public static let shortcut: KeyboardShortcut? = nil
        }
        public enum CloudAccountError: Toolbarable {
            public static let icon: STZ.ICN? = .cloudAccountError
            public static let phrase: Phrase = .iCloudAccountError
            public static let verb: Verb = .iCloud
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
