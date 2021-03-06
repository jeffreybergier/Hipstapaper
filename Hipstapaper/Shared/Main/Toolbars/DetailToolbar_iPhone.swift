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
import Datum

extension DetailToolbar.iOS {
    struct iPhoneEdit: ViewModifier {
        
        let controller: Controller
        @Binding var selection: WH.Selection
        @Binding var popoverAlignment: Alignment
        
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        @EnvironmentObject private var windowPresentation: WindowPresentation
        @EnvironmentObject private var errorQ: ErrorQueue
        @Environment(\.openURL) private var externalPresentation
        
        func body(content: Content) -> some View {
            content
                .toolbar(id: "Detail_Bottom") {
                    ToolbarItem(id: "Detail.Archive", placement: .bottomBar) {
                        STZ.TB.Archive.toolbar(isEnabled: WH.canArchive(self.selection),
                                               action: { WH.archive(self.selection, self.controller, self.errorQ) })
                    }
                    ToolbarItem(id: "Detail.Unarchive", placement: .bottomBar) {
                        STZ.TB.Unarchive.toolbar(isEnabled: WH.canUnarchive(self.selection),
                                                 action: { WH.unarchive(self.selection, self.controller, self.errorQ) })
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
                    ToolbarItem(id: "Detail.OpenExternal", placement: .primaryAction) {
                        STZ.TB.OpenInBrowser.toolbar(isEnabled: WH.canOpen(self.selection, in: self.windowPresentation),
                                                     action: { WH.open(self.selection, in: self.externalPresentation) })
                    }
                }
        }
    }
    
    struct iPhone: ViewModifier {
        
        @Binding var popoverAlignment: Alignment
        @ObservedObject var syncProgress: AnyContinousProgress
        
        @SceneFilter private var filter
        @SceneSearch private var search
        
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        @Environment(\.toolbarFilterIsEnabled) private var toolbarFilterIsEnabled

        
        func body(content: Content) -> some View {
            content.toolbar(id: "Detail") {
                ToolbarItem(id: "Detail.Filter", placement: .bottomBar) {
                    WH.filterToolbarItem(filter: self.filter,
                                         toolbarFilterIsEnabled: self.toolbarFilterIsEnabled)
                    {
                        self.filter.boolValue.toggle()
                    }
                }
                ToolbarItem(id: "Detail.Separator", placement: .bottomBar) {
                    STZ.TB.Separator.toolbar()
                }
                ToolbarItem(id: "Detail.Sort", placement: .bottomBar) {
                    STZ.TB.Sort.toolbar() {
                        self.popoverAlignment = .bottomLeading
                        self.modalPresentation.value = .sort
                    }
                }
                ToolbarItem(id: "Detail.FlexibleSpace", placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(id: "Detail.EditMode", placement: .bottomBar) {
                    EditButton()
                }
                ToolbarItem(id: "Detail.Sync", placement: .cancellationAction) {
                    STZ.TB.Sync(self.syncProgress)
                }
                ToolbarItem(id: "Detail.Search", placement: .primaryAction) {
                    WH.searchToolbarItem(self.search) {
                        self.popoverAlignment = .topTrailing
                        self.modalPresentation.value = .search
                    }
                }
            }
        }
    }
}
