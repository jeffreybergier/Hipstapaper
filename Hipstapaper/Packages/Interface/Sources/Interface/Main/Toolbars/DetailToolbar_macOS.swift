//
//  Created by Jeffrey Bergier on 2021/01/01.
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
import Localize

extension DetailToolbar {
    struct macOS: ViewModifier {
        
        let controller: Controller
        @Binding var selection: WH.Selection
        
        @ErrorQueue private var errorQ
        @QueryProperty private var query
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        @EnvironmentObject private var windowPresentation: WindowPresentation
        @Environment(\.openURL) private var externalPresentation
        @Environment(\.toolbarFilterIsEnabled) private var toolbarFilterIsEnabled
        
        func body(content: Content) -> some View {
            // TODO: Remove combined ToolbarItems when it supoprts more than 10 items
            content.toolbar(id: "Detail") {
                ToolbarItem(id: "Detail.Open") {
                    HStack {
                        STZ.TB.OpenInApp.toolbar(isEnabled: WH.canOpen(self.selection, in: self.windowPresentation),
                                                 action: { WH.open(self.selection, in: self.windowPresentation, self._errorQ.environment) })
                        STZ.TB.OpenInBrowser.toolbar(isEnabled: WH.canOpen(self.selection, in: self.windowPresentation),
                                                     action: { WH.open(self.selection, in: self.externalPresentation) })
                    }
                }
                ToolbarItem(id: "Detail.Share") {
                    STZ.TB.Share.toolbar(isEnabled: WH.canShare(self.selection),
                                         action: { self.modalPresentation.value = .share(self.selection) })
                }
                ToolbarItem(id: "Detail.Separator") {
                    STZ.TB.Separator.toolbar()
                }
                ToolbarItem(id: "Detail.Archive") {
                    HStack {
                        STZ.TB.Archive.toolbar(isEnabled: WH.canArchive(self.selection),
                                               action: { WH.archive(self.selection, self.controller, self._errorQ.environment) })
                        STZ.TB.Unarchive.toolbar(isEnabled: WH.canUnarchive(self.selection),
                                                 action: { WH.unarchive(self.selection, self.controller, self._errorQ.environment) })
                    }
                }
                ToolbarItem(id: "Detail.Tag") {
                    STZ.TB.TagApply.toolbar(isEnabled: WH.canTag(self.selection),
                                            action: { self.modalPresentation.value = .tagApply(selection) })
                }
                ToolbarItem(id: "Detail.Separator") {
                    STZ.TB.Separator.toolbar()
                }
                ToolbarItem(id: "Detail.Sort") {
                    STZ.TB.Sort.toolbar(action: { self.modalPresentation.value = .sort })
                }
                ToolbarItem(id: "Detail.Filter") {
                    WH.filterToolbarItem(query: self.query, toolbarFilterIsEnabled: self.toolbarFilterIsEnabled) {
                        self.query.isOnlyNotArchived.toggle()
                    }
                }
                ToolbarItem(id: "Detail.Search") {
                    WH.searchToolbarItem(self.query.search) {
                        self.modalPresentation.value = .search
                    }
                }
            }
        }
    }
}
