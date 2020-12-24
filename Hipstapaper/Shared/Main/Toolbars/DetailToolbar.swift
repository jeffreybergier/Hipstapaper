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
import Snapshot
import Localize
import Stylize

struct DetailToolbar: View {
    
    @ObservedObject var controller: AnyUIController
    @State var presentation: Presentation.Wrap

    var body: some View {
        HStack {
            ButtonToolbar(systemName: "plus",
                          accessibilityLabel: Verb.AddWebsite)
                { self.presentation.value = .addWebsite }
                .sheet(isPresented: self.$presentation.isAddWebsite) {
                    Snapshotter() { result in
                        switch result {
                        case .success(let output):
                            // TODO: maybe show error to user?
                            try! self.controller.controller.createWebsite(.init(output)).get()
                        case .failure(let error):
                            // TODO: maybe show error to user?
                            break
                        }
                        self.presentation.value = .none
                    }
                }
            
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

            ButtonToolbar(systemName: "tag",
                          accessibilityLabel: Verb.AddAndRemoveTags)
                { self.presentation.value = .tagApply }
                .disabled(self.controller.selectedWebsites.isEmpty)
                .popover(isPresented: self.$presentation.isTagApply, content: { () -> TagApply in
                    return TagApply(controller: self.controller, presentation: self.presentation)
                })
            
            ButtonToolbarShare { self.presentation.value = .share }
                .disabled(self.controller.selectedWebsites.isEmpty)
                .popover(isPresented: self.$presentation.isShare, content: {
                    Share(self.controller.selectedWebsites.compactMap
                    { $0.value.resolvedURL ?? $0.value.originalURL })
                    {
                        self.presentation.value = .none
                    }
                })
            
            // TODO: Make search look different when a search is in effect
            // self.controller.detailQuery.search.nonEmptyString == nil
            ButtonToolbar(systemName: "magnifyingglass",
                          accessibilityLabel: Verb.Search)
                { self.presentation.value = .search }
                .popover(isPresented: self.$presentation.isSearch, content: {
                    Search(controller: self.controller, presentation: self.$presentation)
                })
        }
    }
    
}
