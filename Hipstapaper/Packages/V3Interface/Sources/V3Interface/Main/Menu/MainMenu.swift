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
    
    internal struct State {
        internal var selectedWebsites: Website.Selection = []
        internal var selectedTags: Tag.Selection = []
        internal var canShowErrors: Bool = false
    }
    
    // need to create custom data structure and pass it through environment.... maybe?
    @Nav private var nav
    @V3Style.MainMenu private var style
    
    // Need to hack this because there is no environment in a MENU
    @V3Localize.MainMenu private var localizeKeys
    @ObservedObject private var localizeBundle: LocalizeBundle
    
    // Hack because I can't the controller through the environment
    private let controller: ControllerProtocol?
    @ObservedObject private var state: MainMenuState.Environment
    
    internal init(state: MainMenuState.Environment,
                  controller: ControllerProtocol?,
                  bundle: LocalizeBundle)
    {
        _state = .init(initialValue: state)
        _localizeBundle = .init(initialValue: bundle)
        self.controller = controller
    }
    
    internal var body: some Commands {
        CommandGroup(replacing: .newItem) {
            self.style.websiteAdd.button(self.text(\.websiteAdd),
                                         enabled: self.canWebsiteAdd)
            {
                
            }
            self.style.tagAdd.button(self.text(\.tagAdd),
                                     enabled: self.canTagAdd)
            {
                
            }
        }
        CommandGroup(after: .newItem) {
            Divider()
            self.style.openInApp.button(self.text(\.openInApp),
                                        enabled: self.canOpenInApp)
            {
                
            }
            self.style.openExternal.button(self.text(\.openExternal),
                                           enabled: self.canOpenExternal)
            {
                
            }
        }
        CommandGroup(before: .importExport) {
            self.style.share.button(self.text(\.share),
                                    enabled: self.canShare)
            {
                
            }
        }
        CommandGroup(before: .pasteboard) {
            Divider()
            self.style.archiveYes.button(self.text(\.archiveYes),
                                         enabled: self.canArchiveYes)
            {
                
            }
            self.style.archiveNo.button(self.text(\.archiveNo),
                                        enabled: self.canArchiveNo)
            {
                
            }
            self.style.tagApply.button(self.text(\.tagApply),
                                       enabled: self.canTagApply)
            {
                
            }
            self.style.websiteEdit.button(self.text(\.websiteEdit),
                                          enabled: self.canWebsiteEdit)
            {
                
            }
            self.style.tagEdit.button(self.text(\.tagEdit),
                                      enabled: self.canTagEdit)
            {
                
            }
            Divider()
            self.style.websiteDelete.button(self.text(\.websiteDelete),
                                            enabled: self.canWebsiteDelete)
            {
                
            }
            self.style.tagDelete.button(self.text(\.tagDelete),
                                        enabled: self.canTagDelete)
            {
                
            }
        }
        CommandGroup(after: .sidebar) {
            self.style.error.button(self.text(\.error),
                                    enabled: self.canShowErrors)
            {
                
            }
            Divider()
        }
    }
    
    private func text(_ key: KeyPath<V3Localize.MainMenu.Value, LocalizationKey>) -> LocalizedString {
        self.localizeBundle.localized(key: self.localizeKeys[keyPath: key])
    }
    
    private var canWebsiteAdd: Bool {
        self.controller != nil
    }
    private var canTagAdd: Bool {
        self.controller != nil
    }
    private var canOpenInApp: Bool {
        true
    }
    private var canOpenExternal: Bool {
        true
    }
    private var canShare: Bool {
        !self.state.value.selectedWebsites.isEmpty
    }
    private var canArchiveYes: Bool {
        true
    }
    private var canArchiveNo: Bool {
        true
    }
    private var canTagApply: Bool {
        !self.state.value.selectedWebsites.isEmpty
    }
    private var canWebsiteEdit: Bool {
        !self.state.value.selectedWebsites.isEmpty
    }
    private var canTagEdit: Bool {
        !self.state.value.selectedTags.isEmpty
    }
    private var canWebsiteDelete: Bool {
        !self.state.value.selectedWebsites.isEmpty
    }
    private var canTagDelete: Bool {
        !self.state.value.selectedTags.isEmpty
    }
    private var canShowErrors: Bool {
        self.state.value.canShowErrors
    }
}
