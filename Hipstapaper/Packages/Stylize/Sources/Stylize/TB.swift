//
//  Created by Jeffrey Bergier on 2021/01/11.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI
import Localize

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
            public static let phrase: Phrase = .deleteTagTip
            public static let verb: Verb = .deleteTag
            public static let shortcut: KeyboardShortcut? = .init(.delete, modifiers: [.command])
        }
        public enum DeleteWebsite: Toolbarable {
            public static let icon: STZ.ICN? = .deleteTrash
            public static let phrase: Phrase = .deleteWebsiteTip
            public static let verb: Verb = .deleteWebsite
            public static let shortcut: KeyboardShortcut? = .init(.delete, modifiers: [.command])
        }
        public enum EditWebsite: Toolbarable {
            public static let icon: STZ.ICN? = .editPencil
            public static let phrase: Phrase = .editWebsiteTip
            public static let verb: Verb = .editWebsite
            public static let shortcut: KeyboardShortcut? = .init(.return, modifiers: [.command])
        }
        public enum DeleteTag_Trash: Toolbarable {
            public static let icon: STZ.ICN? = .deleteTrash
            public static let phrase: Phrase = .deleteTagTip
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
