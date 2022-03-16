//
//  Created by Jeffrey Bergier on 2021/01/16.
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
import Stylize
import Datum2

#if os(iOS)

extension DetailToolbar.iOS {
    struct iPadEdit: ViewModifier {
        
        let controller: Controller
        @Binding var selection: WH.Selection
        @Binding var popoverAlignment: Alignment
        
        @QueryProperty private var query
        @ErrorQueue private var errorQ
        
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        @EnvironmentObject private var windowPresentation: WindowPresentation
        @Environment(\.openURL) private var externalPresentation
        @Environment(\.toolbarFilterIsEnabled) private var toolbarFilterIsEnabled
        
        func body(content: Content) -> some View {
            content
                .toolbar(id: "Detail_Bottom") {
                    ToolbarItem(id: "Detail.Archive", placement: .bottomBar) {
                        STZ.TB.Archive.toolbar(isEnabled: WH.canArchive(self.selection),
                                               action: { WH.archive(self.selection, self.controller, self._errorQ.environment) })
                    }
                    ToolbarItem(id: "Detail.Unarchive", placement: .bottomBar) {
                        STZ.TB.Unarchive.toolbar(isEnabled: WH.canUnarchive(self.selection),
                                                 action: { WH.unarchive(self.selection, self.controller, self._errorQ.environment) })
                    }
                    ToolbarItem(id: "Detail.Separator", placement: .bottomBar) {
                        STZ.TB.Separator.toolbar()
                    }
                    ToolbarItem(id: "Detail.Tag", placement: .bottomBar) {
                        STZ.TB.TagApply.toolbar(isEnabled: WH.canTag(self.selection)) {
                            self.popoverAlignment = .bottomLeading
                            self.modalPresentation.value = .tagApply(self.selection)
                        }
                    }
                    ToolbarItem(id: "Detail.FlexibleSpace", placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(id: "Detail.OpenInApp", placement: .bottomBar) {
                        STZ.TB.OpenInApp.toolbar(isEnabled: WH.canOpen(self.selection, in: self.windowPresentation)) {
                            self.modalPresentation.value = .browser(selection.first!)
                        }
                    }
                    ToolbarItem(id: "Detail.OpenExternal", placement: .bottomBar) {
                        STZ.TB.OpenInBrowser.toolbar(isEnabled: WH.canOpen(self.selection, in: self.windowPresentation),
                                                     action: { WH.open(self.selection, in: self.externalPresentation) })
                    }
                    ToolbarItem(id: "Detail.Separator", placement: .bottomBar) {
                        STZ.TB.Separator.toolbar()
                    }
                    ToolbarItem(id: "Detail.Share", placement: .bottomBar) {
                        STZ.TB.Share.toolbar(isEnabled: WH.canShare(self.selection)) {
                            self.popoverAlignment = .bottomTrailing
                            self.modalPresentation.value = .share(self.selection)
                        }
                    }
                    ToolbarItem(id: "Detail.EditMode", placement: .bottomBar) {
                        EditButton()
                    }
                }
                .toolbar(id: "Detail") { // TODO: Hack because toolbars only support 10 items
                    ToolbarItem(id: "Detail.Sync", placement: .cancellationAction) {
                        STZ.TB.Sync(self.controller.syncProgress)
                    }
                    ToolbarItem(id: "Detail.Sort") {
                        STZ.TB.Sort.toolbar() {
                            self.popoverAlignment = .topTrailing
                            self.modalPresentation.value = .sort
                        }
                    }
                    ToolbarItem(id: "Detail.Filter") {
                        WH.filterToolbarItem(query: self.query,
                                             toolbarFilterIsEnabled: self.toolbarFilterIsEnabled)
                        {
                            self.popoverAlignment = .topTrailing
                            self.query.isOnlyNotArchived.toggle()
                        }
                    }
                    ToolbarItem(id: "Detail.Search") {
                        WH.searchToolbarItem(self.query.search) {
                            self.popoverAlignment = .topTrailing
                            self.modalPresentation.value = .search
                        }
                    }
                }
        }
    }
    
    struct iPad: ViewModifier {
        
        @Binding var popoverAlignment: Alignment
        @ObservedObject var syncProgress: AnyContinousProgress
        
        @QueryProperty private var query
        
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        @Environment(\.toolbarFilterIsEnabled) private var toolbarFilterIsEnabled
        
        func body(content: Content) -> some View {
            // TODO: Remove combined ToolbarItems when it supoprts more than 10 items
            content.toolbar(id: "Detail") {
                ToolbarItem(id: "Detail.FlexibleSpace", placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(id: "Detail.EditMode", placement: .bottomBar) {
                    EditButton()
                }
                ToolbarItem(id: "Detail.Sync", placement: .cancellationAction) {
                    STZ.TB.Sync(self.syncProgress)
                }
                ToolbarItem(id: "Detail.Sort") {
                    STZ.TB.Sort.toolbar() {
                        self.popoverAlignment = .topTrailing
                        self.modalPresentation.value = .sort
                    }
                }
                ToolbarItem(id: "Detail.Filter") {
                    WH.filterToolbarItem(query: self.query,
                                         toolbarFilterIsEnabled: self.toolbarFilterIsEnabled)
                    {
                        self.popoverAlignment = .topTrailing
                        self.query.isOnlyNotArchived.toggle()
                    }
                }
                ToolbarItem(id: "Detail.Search") {
                    WH.searchToolbarItem(self.query.search) {
                        self.popoverAlignment = .topTrailing
                        self.modalPresentation.value = .search
                    }
                }
            }
        }
    }
}

#endif
