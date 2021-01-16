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
    @EnvironmentObject private var presentation: ModalPresentation.Wrap

    @Environment(\.openURL) var openURL
    @EnvironmentObject var windowManager: WindowPresentation
    
    func body(content: Content) -> some View {
        // TODO: Remove combined ToolbarItems when it supoprts more than 10 items
        content.toolbar(id: "Detail_Mac") {
            ToolbarItem(id: "Detail_Mac.OpenInApp") {
                HStack {
                    STZ.TB.OpenInApp.toolbar(isEnabled: !self.controller.selectedWebsites.isEmpty)
                    {
                        let allURLs = self.controller.selectedWebsites.compactMap { $0.value.preferredURL }
                        guard allURLs.isEmpty == false else { fatalError("Maybe present an error?") }
                        guard self.windowManager.features.contains(.multipleWindows) else {
                            self.presentation.value = .browser(self.controller.selectedWebsites.first!)
                            return
                        }
                        let urls = self.windowManager.features.contains(.bulkActivation)
                            ? Set(allURLs)
                            : Set([allURLs.first!])
                        self.windowManager.show(urls) {
                            // TODO: Do something with this error
                            print($0)
                        }
                    }
                    STZ.TB.OpenInBrowser.toolbar(isEnabled: !self.controller.selectedWebsites.isEmpty)
                    {
                        let urls = self.controller.selectedWebsites.compactMap { $0.value.preferredURL }
                        urls.forEach { self.openURL($0) }
                    }
                }
            }
            ToolbarItem(id: "Detail_Mac.Share") {
                STZ.TB.Share.toolbar(isEnabled: !self.controller.selectedWebsites.isEmpty,
                                           action: { self.presentation.value = .share })
            }
            ToolbarItem(id: "Detail_Mac.Separator") {
                STZ.TB.Separator.toolbar()
            }
            ToolbarItem(id: "Detail_Mac.Archive") {
                HStack {
                    STZ.TB.Archive.toolbar(isEnabled: !self.controller.selectedWebsites.filter { !$0.value.isArchived }.isEmpty)
                    {
                        // Archive
                        let selected = self.controller.selectedWebsites
                        self.controller.selectedWebsites = []
                        try! self.controller.controller.update(selected, .init(isArchived: true)).get()
                    }
                    STZ.TB.Unarchive.toolbar(isEnabled: !self.controller.selectedWebsites.filter { $0.value.isArchived }.isEmpty)
                    {
                        // Unarchive
                        let selected = self.controller.selectedWebsites
                        self.controller.selectedWebsites = []
                        try! self.controller.controller.update(selected, .init(isArchived: false)).get()
                    }
                }
            }
            ToolbarItem(id: "Detail_Mac.Tag") {
                STZ.TB.TagApply.toolbar(isEnabled: !self.controller.selectedWebsites.isEmpty,
                                              action: { self.presentation.value = .tagApply })
            }
            ToolbarItem(id: "Detail_Mac.Separator") {
                STZ.TB.Separator.toolbar()
            }
            ToolbarItem(id: "Detail_Mac.Sort") {
                STZ.TB.Sort.toolbar(action: { self.presentation.value = .sort })
            }
            ToolbarItem(id: "Detail_Mac.Filter") {
                return self.controller.query.isArchived.boolValue
                    ? AnyView(STZ.TB.FilterActive.toolbar(action: { self.controller.query.isArchived.toggle() }))
                    : AnyView(STZ.TB.FilterInactive.toolbar(action: { self.controller.query.isArchived.toggle() }))
            }
            ToolbarItem(id: "Detail_Mac.Search") {
                return self.controller.query.search.nonEmptyString == nil
                    ? AnyView(STZ.TB.SearchInactive.toolbar(action: { self.presentation.value = .search }))
                    : AnyView(STZ.TB.SearchActive.toolbar(action: { self.presentation.value = .search }))
            }
        }
    }
}
