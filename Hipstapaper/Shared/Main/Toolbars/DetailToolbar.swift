//
//  Created by Jeffrey Bergier on 2020/12/03.
//
//  Copyright © 2020 Saturday Apps.
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
import Datum
import Localize
import Stylize
import Browse

struct DetailToolbar: ViewModifier {
    
    @ObservedObject var controller: AnyUIController
    @Environment(\.openURL) var openURL
    @State var isSearch = false
    @State var isTagApply = false
    @State var isShare = false
    @State var isBrowser = false
    
    func body(content: Content) -> some View {
        return ZStack(alignment: Alignment.topTrailing) {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .sheet(isPresented: self.$isBrowser) {
                    let site = self.controller.selectedWebsites.first!.value
                    let url = site.resolvedURL ?? site.originalURL
                    Browser(url: url!, done: { self.isBrowser = false })
                }
            
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$isTagApply) { () -> TagApply in
                    return TagApply(controller: self.controller, done: { self.isTagApply = false })
                }
            
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$isShare) {
                    Share(self.controller.selectedWebsites.compactMap
                    { $0.value.resolvedURL ?? $0.value.originalURL })
                    { self.isShare = false }
                }
            
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$isSearch) {
                    Search(controller: self.controller,
                           doneAction: { self.isSearch = false })
                }
            
            
            content.toolbar(id: "Detail") {
                ToolbarItem(id: "Detail.0") {
                    ButtonToolbar(systemName: "safari", accessibilityLabel: Verb.Open, action: { self.isBrowser = true })
                        .keyboardShortcut("o")
                        .modifier(OpenWebsiteDisabler(selectedWebsites: self.controller.selectedWebsites))
                }
                ToolbarItem(id: "Detail.1") {
                    ButtonToolbar(systemName: "safari.fill", accessibilityLabel: Verb.Safari) {
                        let urls = self.controller.selectedWebsites
                            .compactMap { $0.value.resolvedURL ?? $0.value.originalURL }
                        urls.forEach { self.openURL($0) }
                    }
                    .keyboardShortcut("O")
                    .modifier(OpenWebsiteDisabler(selectedWebsites: self.controller.selectedWebsites))
                }
                ToolbarItem(id: "Detail.2") {
                    ButtonToolbar(systemName: "tray.and.arrow.down",
                                  accessibilityLabel: Verb.Archive)
                    {
                        // Archive
                        self.controller.selectedWebsites
                            .filter { !$0.value.isArchived }
                            .forEach { try! self.controller.controller
                                .update($0, .init(isArchived: true)).get()
                            }
                    }
                    .disabled(self.controller.selectedWebsites.filter { !$0.value.isArchived }.isEmpty)
                }
                ToolbarItem(id: "Detail.3") {
                    ButtonToolbar(systemName: "tray.and.arrow.up",
                                  accessibilityLabel: Verb.Unarchive)
                    {
                        // Unarchive
                        self.controller.selectedWebsites
                            .filter { $0.value.isArchived }
                            .forEach { try! self.controller.controller
                                .update($0, .init(isArchived: false)).get()
                            }
                    }
                    .disabled(self.controller.selectedWebsites.filter { $0.value.isArchived }.isEmpty)
                }
                ToolbarItem(id: "Detail.4") {
                    ButtonToolbar(systemName: "tag",
                                  accessibilityLabel: Verb.AddAndRemoveTags)
                        { self.isTagApply = true }
                        .disabled(self.controller.selectedWebsites.isEmpty)
                }
                ToolbarItem(id: "Detail.5") {
                    ButtonToolbarShare { self.isShare = true }
                        .disabled(self.controller.selectedWebsites.isEmpty)
                }
                ToolbarItem(id: "Detail.6") {
                    // TODO: Make search look different when a search is in effect
                    // self.controller.detailQuery.search.nonEmptyString == nil
                    ButtonToolbar(systemName: "magnifyingglass",
                                  accessibilityLabel: Verb.Search,
                                  action: { self.isSearch = true })
                }
            }
        }
    }
}

fileprivate struct OpenWebsiteDisabler: ViewModifier {
    
    let selectedWebsites: Set<AnyElement<AnyWebsite>>
    
    func body(content: Content) -> some View {
        #if os(macOS)
        return content.disabled(self.selectedWebsites.isEmpty)
        #else
        return content.disabled(self.selectedWebsites.count != 1)
        #endif
    }
    
}
