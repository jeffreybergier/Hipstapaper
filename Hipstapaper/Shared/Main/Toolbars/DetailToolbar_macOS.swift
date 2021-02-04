//
//  Created by Jeffrey Bergier on 2021/01/01.
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

extension DetailToolbar {
    struct macOS: ViewModifier {
        
        @ObservedObject var dataSource: WebsiteDataSource
        
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        @EnvironmentObject private var windowPresentation: WindowPresentation
        @EnvironmentObject private var errorQ: STZ.ERR.ViewModel
        @Environment(\.openURL) private var externalPresentation
        
        func body(content: Content) -> some View {
            // TODO: Remove combined ToolbarItems when it supoprts more than 10 items
            content.toolbar(id: "Detail") {
                ToolbarItem(id: "Detail.Open") {
                    HStack {
                        STZ.TB.OpenInApp.toolbar(isEnabled: self.dataSource.canOpen(in: self.windowPresentation),
                                                 action: { self.dataSource.open(in: self.windowPresentation) })
                        STZ.TB.OpenInBrowser.toolbar(isEnabled: self.dataSource.canOpen(in: self.windowPresentation),
                                                     action: { self.dataSource.open(in: self.externalPresentation) })
                    }
                }
                ToolbarItem(id: "Detail.Share") {
                    STZ.TB.Share.toolbar(isEnabled: self.dataSource.canShare(),
                                         action: { self.modalPresentation.value = .share })
                }
                ToolbarItem(id: "Detail.Separator") {
                    STZ.TB.Separator.toolbar()
                }
                ToolbarItem(id: "Detail.Archive") {
                    HStack {
                        STZ.TB.Archive.toolbar(isEnabled: self.dataSource.canArchive(),
                                               action: { self.dataSource.archive(self.errorQ) })
                        STZ.TB.Unarchive.toolbar(isEnabled: self.dataSource.canUnarchive(),
                                                 action: { self.dataSource.unarchive(self.errorQ) })
                    }
                }
                ToolbarItem(id: "Detail.Tag") {
                    STZ.TB.TagApply.toolbar(isEnabled: self.dataSource.canTag(),
                                            action: { self.modalPresentation.value = .tagApply })
                }
                ToolbarItem(id: "Detail.Separator") {
                    STZ.TB.Separator.toolbar()
                }
                ToolbarItem(id: "Detail.Sort") {
                    STZ.TB.Sort.toolbar(action: { self.modalPresentation.value = .sort })
                }
                ToolbarItem(id: "Detail.Filter") {
                    return self.dataSource.isFiltered()
                        ? AnyView(STZ.TB.FilterActive.toolbar(action: self.dataSource.toggleFilter))
                        : AnyView(STZ.TB.FilterInactive.toolbar(action: self.dataSource.toggleFilter))
                }
                ToolbarItem(id: "Detail.Search") {
                    return self.dataSource.isSearchActive()
                        ? AnyView(STZ.TB.SearchInactive.toolbar(action: { self.modalPresentation.value = .search }))
                        : AnyView(STZ.TB.SearchActive.toolbar(action: { self.modalPresentation.value = .search }))
                }
            }
        }
    }
}
