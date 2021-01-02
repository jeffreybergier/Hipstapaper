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

struct DetailToolbar_macOS: ViewModifier {
    
    @ObservedObject var controller: WebsiteController
    @Binding var presentation: DetailToolbarPresentation.Wrap
    
    @Environment(\.openURL) var openURL
    @EnvironmentObject var windowManager: WindowManager
    
    func body(content: Content) -> some View {
        // TODO: Remove combined ToolbarItems when it supoprts more than 10 items
        content.toolbar(id: "Detail_Mac") {
            ToolbarItem(id: "Detail_Mac.OpenInApp") {
                HStack {
                    DT.OpenInApp(selectionCount: self.controller.selectedWebsites.count) {
                        guard self.windowManager.features.contains([.multipleWindows, .bulkActivation])
                        else { self.presentation.value = .browser; return }
                        let urls = self.controller.selectedWebsites.compactMap
                        { $0.value.resolvedURL ?? $0.value.originalURL }
                        self.windowManager.show(urls) {
                            // TODO: Do something with this error
                            print($0)
                        }
                    }
                    DT.OpenExternal(selectionCount: self.controller.selectedWebsites.count) {
                        let urls = self.controller.selectedWebsites
                            .compactMap { $0.value.resolvedURL ?? $0.value.originalURL }
                        urls.forEach { self.openURL($0) }
                    }
                }
            }
            ToolbarItem(id: "Detail_Mac.Share") {
                DT.Share(isDisabled: self.controller.selectedWebsites.isEmpty,
                         action: { self.presentation.value = .share })
            }
            ToolbarItem(id: "Detail_Mac.Separator") {
                ButtonToolbarSeparator()
            }
            ToolbarItem(id: "Detail_Mac.Archive") {
                HStack {
                    DT.Archive(isDisabled: self.controller.selectedWebsites.filter { !$0.value.isArchived }.isEmpty)
                    {
                        // Archive
                        let selected = self.controller.selectedWebsites
                        self.controller.selectedWebsites = []
                        try! self.controller.controller.update(selected, .init(isArchived: true)).get()
                    }
                    DT.Unarchive(isDisabled: self.controller.selectedWebsites.filter { $0.value.isArchived }.isEmpty)
                    {
                        // Unarchive
                        let selected = self.controller.selectedWebsites
                        self.controller.selectedWebsites = []
                        try! self.controller.controller.update(selected, .init(isArchived: false)).get()
                    }
                }
            }
            ToolbarItem(id: "Detail_Mac.Tag") {
                DT.Tag(isDisabled: self.controller.selectedWebsites.isEmpty,
                       action: { self.presentation.value = .tagApply })
            }
            ToolbarItem(id: "Detail_Mac.Separator") {
                ButtonToolbarSeparator()
            }
            ToolbarItem(id: "Detail_Mac.Sort") {
                ButtonToolbarSort { self.presentation.value = .sort }
            }
            ToolbarItem(id: "Detail_Mac.Filter") {
                DT.Filter(filter: self.controller.query.isArchived) {
                    self.controller.query.isArchived.toggle()
                }
            }
            ToolbarItem(id: "Detail_Mac.Search") {
                DT.Search(searchActive: self.controller.query.search.nonEmptyString != nil) {
                    self.presentation.value = .search
                }
            }
        }
    }
}
