//
//  Created by Jeffrey Bergier on 2020/12/05.
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
import Snapshot

struct IndexToolbar: ViewModifier {
    
    @ObservedObject var controller: AnyUIController
    @State var isAddWebsite = false
    @State var isAddTag = false
    @State var isAddChoose = false
    
    func body(content: Content) -> some View {
        return ZStack(alignment: Alignment.topTrailing) {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1).popover(isPresented: self.$isAddTag) {
                AddTag(
                    cancel: { self.isAddTag = false },
                    save: {
                        let result = self.controller.controller.createTag(name: $0)
                        switch result {
                        case .success:
                            self.isAddTag = false
                        case .failure(let error):
                            // TODO: Do something with this error
                            break
                        }
                    }
                )
            }
            
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1).sheet(isPresented: self.$isAddWebsite) {
                Snapshotter() { result in
                    switch result {
                    case .success(let output):
                        // TODO: maybe show error to user?
                        try! self.controller.controller.createWebsite(.init(output)).get()
                    case .failure(let error):
                        // TODO: maybe show error to user?
                        break
                    }
                    self.isAddWebsite = false
                }
            }
            
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1).modifier(
                ActionSheet(
                    isPresented: self.$isAddChoose,
                    title: Phrase.AddChoice,
                    buttons: [
                        .init(title: Verb.AddTag,
                              action: { self.isAddTag = true }),
                        .init(title: Verb.AddWebsite,
                              action: { self.isAddWebsite = true })
                    ]
                )
            )
            
            content.toolbar(id: "Index") {
                // TODO: Move into ToolbarItems
                // For some reason on iOS, it only shows 1 of the 2 items
                ToolbarItem(id: "Index.0", placement: .destructiveAction) {
                    ButtonToolbar(systemName: "minus",
                                  accessibilityLabel: Verb.DeleteTag)
                    {
                        // Delete
                        guard let tag = self.controller.selectedTag else { return }
                        try! self.controller.controller.delete(tag).get()
                    }
                    .disabled({
                        guard let tag = self.controller.selectedTag else { return true }
                        return tag.value.wrappedValue as? Query.Archived != nil
                    }())
                }
                ToolbarItem(id: "Index.1", placement: .confirmationAction) {
                    ButtonToolbar(systemName: "plus",
                                  accessibilityLabel: Verb.AddTag,
                                  action: { self.isAddChoose = true })
                }
                
            }
        }
    }
}
