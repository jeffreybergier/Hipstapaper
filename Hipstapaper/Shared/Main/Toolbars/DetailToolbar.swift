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
    
    @ObservedObject var controller: WebsiteController
    @State var presentation = DetailToolbarPresentation.Wrap()

    @Environment(\.openURL) var openURL
    @EnvironmentObject var windowManager: WindowManager
    
    func body(content: Content) -> some View {
        return ZStack(alignment: Alignment.topTrailing) {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .sheet(isPresented: self.$presentation.isBrowser) {
                    let site = self.controller.selectedWebsites.first!.value
                    let url = site.resolvedURL ?? site.originalURL
                    Browser(url: url!, done: { self.presentation.value = .none })
                }
            
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$presentation.isTagApply) { () -> TagApply in
                    return TagApply(controller: self.controller,
                                    done: { self.presentation.value = .none })
                }
            
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$presentation.isShare) {
                    Share(self.controller.selectedWebsites.compactMap
                    { $0.value.resolvedURL ?? $0.value.originalURL })
                    { self.presentation.value = .none }
                }
            
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$presentation.isSearch) {
                    Search(searchString: self.$controller.query.search,
                           doneAction: { self.presentation.value = .none })
                }
            
            
            content.toolbar(id: "Detail") {
                ToolbarItem(id: "Detail.0") {
                    ButtonToolbar(systemName: "safari",
                                  accessibilityLabel: Verb.Open,
                                  action: {
                                    guard self.windowManager.features.contains([.multipleWindows, .bulkActivation])
                                    else { self.presentation.value = .browser; return }
                                    let urls = self.controller.selectedWebsites.compactMap
                                    { $0.value.resolvedURL ?? $0.value.originalURL }
                                    self.windowManager.show(urls) {
                                        // TODO: Do something with this error
                                        print($0)
                                    }
                                  })
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
                        self.controller
                            .selectedWebsites
                            .filter { !$0.value.isArchived }
                            .forEach { try! self.controller.controller.update($0, .init(isArchived: true)).get() }
                    }
                    .disabled(self.controller.selectedWebsites.filter { !$0.value.isArchived }.isEmpty)
                }
                ToolbarItem(id: "Detail.3") {
                    ButtonToolbar(systemName: "tray.and.arrow.up",
                                  accessibilityLabel: Verb.Unarchive)
                    {
                        // Unarchive
                        self.controller
                            .selectedWebsites
                            .filter { $0.value.isArchived }
                            .forEach { try! self.controller.controller.update($0, .init(isArchived: false)).get() }
                    }
                    .disabled(self.controller.selectedWebsites.filter { $0.value.isArchived }.isEmpty)
                }
                ToolbarItem(id: "Detail.4") {
                    ButtonToolbar(systemName: "tag",
                                  accessibilityLabel: Verb.AddAndRemoveTags,
                                  action: { self.presentation.value = .tagApply })
                        .disabled(self.controller.selectedWebsites.isEmpty)
                }
                ToolbarItem(id: "Detail.5") {
                    ButtonToolbarShare { self.presentation.value = .share }
                        .disabled(self.controller.selectedWebsites.isEmpty)
                }
                ToolbarItem(id: "Detail.6") {
                    // TODO: Make search look different when a search is in effect
                    // self.controller.detailQuery.search.nonEmptyString == nil
                    ButtonToolbar(systemName: "magnifyingglass",
                                  accessibilityLabel: Verb.Search,
                                  action: { self.presentation.value = .search })
                }
            }
        }
    }
}

fileprivate struct OpenWebsiteDisabler: ViewModifier {
    
    let selectedWebsites: Set<AnyElement<AnyWebsite>>
    @EnvironmentObject var windowManager: WindowManager
    
    func body(content: Content) -> some View {
        if self.windowManager.features.contains(.bulkActivation) {
            return content.disabled(self.selectedWebsites.isEmpty)
        } else {
            return content.disabled(self.selectedWebsites.count != 1)
        }
    }
}
