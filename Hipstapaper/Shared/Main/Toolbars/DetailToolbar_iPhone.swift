//
//  Created by Jeffrey Bergier on 2021/01/16.
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
import Umbrella
import Stylize
import Datum

extension DetailToolbar.iOS {
    struct iPhoneEdit: ViewModifier {
        
        let controller: Controller
        @Binding var selection: WH.Selection
        @Binding var query: Query
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
                        STZ.TB.SyncMonitor(self.controller.syncMonitor)
                    }
                    ToolbarItem(id: "Detail.OpenExternal", placement: .primaryAction) {
                        STZ.TB.OpenInBrowser.toolbar(isEnabled: WH.canOpen(self.selection, in: self.windowPresentation),
                                                     action: { WH.open(self.selection, in: self.externalPresentation) })
                    }
                }
        }
        
        private func search() {
            self.popoverAlignment = .topTrailing
            self.modalPresentation.value = .search
        }
    }
    
    struct iPhone: ViewModifier {
        
        @Binding var query: Query
        @Binding var popoverAlignment: Alignment
        @ObservedObject var syncMonitor: AnySyncMonitor
        
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        
        func body(content: Content) -> some View {
            content.toolbar(id: "Detail") {
                ToolbarItem(id: "Detail.Filter", placement: .bottomBar) {
                    WH.filterToolbarItem(self.query.filter) {
                        self.query.filter.boolValue.toggle()
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
                    STZ.TB.SyncMonitor(self.syncMonitor)
                }
                ToolbarItem(id: "Detail.Search", placement: .primaryAction) {
                    WH.searchToolbarItem(self.query) {
                        self.modalPresentation.value = .search
                    }
                }
            }
        }
        
        private func search() {
            self.popoverAlignment = .topTrailing
            self.modalPresentation.value = .search
        }
    }
}
