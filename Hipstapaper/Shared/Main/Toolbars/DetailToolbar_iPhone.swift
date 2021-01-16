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
import Stylize

extension DetailToolbar.iOS {
    struct iPhoneEdit: ViewModifier {
        
        @ObservedObject var controller: WebsiteController
        @Binding var popoverAlignment: Alignment
        
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        @EnvironmentObject private var windowPresentation: WindowPresentation
        @Environment(\.openURL) private var externalPresentation
        
        func body(content: Content) -> some View {
            content
                .toolbar(id: "Detail_Bottom") {
                    ToolbarItem(id: "Detail.Archive", placement: .bottomBar) {
                        STZ.TB.Archive.toolbar(isEnabled: self.controller.canArchive(),
                                               action: self.controller.archive)
                    }
                    ToolbarItem(id: "Detail.Unarchive", placement: .bottomBar) {
                        STZ.TB.Unarchive.toolbar(isEnabled: self.controller.canUnarchive(),
                                                 action: self.controller.unarchive)
                    }
                    ToolbarItem(id: "Detail.Separator", placement: .bottomBar) {
                        STZ.TB.Separator.toolbar()
                    }
                    ToolbarItem(id: "Detail.Tag", placement: .bottomBar) {
                        STZ.TB.TagApply.toolbar(isEnabled: self.controller.canTag()) {
                            self.popoverAlignment = .bottomLeading
                            self.modalPresentation.value = .tagApply
                        }
                    }
                    ToolbarItem(id: "Detail.FlexibleSpace", placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(id: "Detail.Share", placement: .bottomBar) {
                        STZ.TB.Share.toolbar(isEnabled: self.controller.canShare()) {
                            self.popoverAlignment = .bottomTrailing
                            self.modalPresentation.value = .share
                        }
                    }
                    ToolbarItem(id: "Detail.EditMode", placement: .bottomBar) {
                        EditButton()
                    }
                }
                .toolbar(id: "Detail") { // TODO: Hack because toolbars only support 10 items
                    ToolbarItem(id: "Detail.OpenExternal", placement: .primaryAction) {
                        STZ.TB.OpenInBrowser.toolbar(isEnabled: self.controller.canOpen(in: self.windowPresentation),
                                                     action: { self.controller.open(in: self.externalPresentation) })
                    }
                }
        }
        
        private func search() {
            self.popoverAlignment = .topTrailing
            self.modalPresentation.value = .search
        }
    }
    
    struct iPhone: ViewModifier {
        
        @ObservedObject var controller: WebsiteController
        @Binding var popoverAlignment: Alignment
        
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        
        func body(content: Content) -> some View {
            content.toolbar(id: "Detail") {
                ToolbarItem(id: "Detail.Filter", placement: .bottomBar) {
                    return self.controller.isFiltered()
                        ? AnyView(STZ.TB.FilterActive.toolbar(action: self.controller.toggleFilter))
                        : AnyView(STZ.TB.FilterInactive.toolbar(action: self.controller.toggleFilter))
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
                ToolbarItem(id: "Detail.Search", placement: .primaryAction) {
                    return self.controller.isSearchActive()
                        ? AnyView(STZ.TB.SearchInactive.toolbar(action: self.search))
                        : AnyView(STZ.TB.SearchActive.toolbar(action: self.search))
                }
            }
        }
        
        private func search() {
            self.popoverAlignment = .topTrailing
            self.modalPresentation.value = .search
        }
    }
}