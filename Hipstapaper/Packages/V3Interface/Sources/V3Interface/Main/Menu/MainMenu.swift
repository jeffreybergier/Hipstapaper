//
//  Created by Jeffrey Bergier on 2022/07/20.
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
import Umbrella
import V3Style
import V3Localize

internal struct MainMenu: Commands {
    
    // need to create custom data structure and pass it through environment.... maybe?
    @Nav private var nav
    @V3Style.MainMenu private var style
    
    // Need to hack this because there is no environment in a MENU
    @V3Localize.MainMenu private var localizeKeys
    @ObservedObject private var localizeBundle: LocalizeBundle
    
    internal init(bundle: LocalizeBundle) {
        _localizeBundle = .init(initialValue: bundle)
    }
    
    internal var body: some Commands {
        CommandGroup(replacing: .newItem) {
            self.style.websiteAdd.button(self.text(\.websiteAdd), action: {})
            self.style.tagAdd.button(self.text(\.tagAdd), action: {})
        }
        CommandGroup(after: .newItem) {
            Divider()
            self.style.openInApp.button(self.text(\.openInApp), action: {})
            self.style.openExternal.button(self.text(\.openExternal), action: {})
        }
        CommandGroup(before: .importExport) {
            self.style.share.button(self.text(\.share), action: {})
        }
        CommandGroup(before: .pasteboard) {
            Divider()
            self.style.archiveYes.button(self.text(\.archiveYes), action: {})
            self.style.archiveNo.button(self.text(\.archiveNo), action: {})
            self.style.tagApply.button(self.text(\.tagApply), action: {})
            self.style.websiteEdit.button(self.text(\.websiteEdit), action: {})
            self.style.tagEdit.button(self.text(\.tagEdit), action: {})
            Divider()
            self.style.websiteDelete.button(self.text(\.websiteDelete), action: {})
            self.style.tagDelete.button(self.text(\.tagDelete), action: {})
        }
        CommandGroup(after: .sidebar) {
            self.style.error.button(self.text(\.error), action: {})
            Divider()
        }
    }
    
    private func text(_ key: KeyPath<V3Localize.MainMenu.Value, LocalizationKey>) -> LocalizedString {
        self.localizeBundle.localized(key: self.localizeKeys[keyPath: key])
    }
}
