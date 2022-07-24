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
import V3Model
import V3Store
import V3Style
import V3Localize

internal struct MainMenu: Commands {
    
    // need to create custom data structure and pass it through environment.... maybe?
    @Nav private var nav
    @V3Style.MainMenu private var style
    
    // Need to hack this because there is no environment in a MENU
    @V3Localize.MainMenu private var localizeKeys
    @ObservedObject private var localizeBundle: LocalizeBundle
    
    // Hack because I can't the controller through the environment
    @ObservedObject private var _controller: Controller.Environment
    @ObservedObject private var _state: BulkActions.Environment
    
    private var controller: ControllerProtocol? { _controller.value.value }
    private var state: BulkActions.State {
        get { _state.value }
        nonmutating set { _state.value = newValue }
    }
    
    internal init(state: BulkActions.Environment,
                  controller: Controller.Environment,
                  bundle: LocalizeBundle)
    {
        __state = .init(initialValue: state)
        __controller = .init(initialValue: controller)
        _localizeBundle = .init(initialValue: bundle)
    }
    
    internal var body: some Commands {
        CommandGroup(replacing: .newItem) {
            self.style.websiteAdd.button(self.text(\.websiteAdd),
                                         enabled: self.controller)
            { _ in
                self.state.push.websiteAdd = true
            }
            self.style.tagAdd.button(self.text(\.tagAdd),
                                     enabled: self.controller)
            { _ in
                self.state.push.tagAdd = true
            }
        }
        CommandGroup(after: .newItem) {
            Divider()
            self.style.openInApp.button(self.text(\.openInApp),
                                        enabled: self.state.pull.openInApp?.single)
            { _ in
                self.state.push.openInApp = self.state.pull.openInApp

            }
            self.style.openExternal.button(self.text(\.openExternal),
                                           enabled: self.state.pull.openExternal?.single)
            { _ in
                self.state.push.openExternal = self.state.pull.openExternal
            }
        }
        CommandGroup(before: .importExport) {
            self.style.share.button(self.text(\.share),
                                    enabled: self.state.pull.share)
            {
                self.state.push.share = $0
            }
        }
        CommandGroup(before: .pasteboard) {
            Divider()
            self.style.archiveYes.button(self.text(\.archiveYes),
                                         enabled: self.state.pull.archiveYes)
            {
                self.state.push.archiveYes = $0
            }
            self.style.archiveNo.button(self.text(\.archiveNo),
                                        enabled: self.state.pull.archiveNo)
            {
                self.state.push.archiveNo = $0
            }
            self.style.tagApply.button(self.text(\.tagApply),
                                       enabled: self.state.pull.tagApply)
            {
                self.state.push.tagApply = $0
            }
            self.style.websiteEdit.button(self.text(\.websiteEdit),
                                          enabled: self.state.pull.websiteEdit)
            {
                self.state.push.websiteEdit = $0
            }
            self.style.tagEdit.button(self.text(\.tagEdit),
                                      enabled: self.state.pull.tagsEdit)
            {
                self.state.push.tagsEdit = $0
            }
            Divider()
            self.style.websiteDelete.button(self.text(\.websiteDelete),
                                            enabled: self.state.pull.websiteDelete)
            {
                self.state.push.websiteDelete = $0
            }
            self.style.tagDelete.button(self.text(\.tagDelete),
                                        enabled: self.state.pull.tagDelete)
            {
                self.state.push.tagDelete = $0
            }
        }
        CommandGroup(after: .sidebar) {
            self.style.error.button(self.text(\.error),
                                    enabled: self.state.pull.showErrors)
            {
                self.state.push.showErrors = true
            }
            Divider()
        }
    }
    
    private func text(_ key: KeyPath<V3Localize.MainMenu.Value, LocalizationKey>) -> LocalizedString {
        self.localizeBundle.localized(key: self.localizeKeys[keyPath: key])
    }
}
