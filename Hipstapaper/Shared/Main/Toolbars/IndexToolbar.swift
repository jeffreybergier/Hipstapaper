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

struct _IndexToolbar: ViewModifier {
    
    @ObservedObject var controller: AnyUIController
    @Binding var presentation: Presentation.Wrap
    
    func body(content: Content) -> some View {
        return content.toolbar {
            // TODO: Move into ToolbarItems
            // For some reason on iOS, it only shows 1 of the 2 items
            HStack {
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
                
                ZStack() {
                    // TODO: Hack to give the popover something to attach to
                    Color.clear.popover(isPresented: self.$presentation.isAddTag, content: {
                        AddTag(controller: self.controller.controller, presentation: self.$presentation)
                    })
                    ButtonToolbar(systemName: "plus",
                                  accessibilityLabel: Verb.AddTag)
                        { self.presentation.isAddChoose = true }
                        .modifier(ActionSheet(
                                    isPresented: self.$presentation.isAddChoose,
                                    title: Phrase.AddChoice,
                                    buttons: [
                                        .init(title: Verb.AddTag,
                                              action: { self.presentation.isAddTag = true }),
                                        .init(title: Verb.AddWebsite,
                                              action: { self.presentation.isAddWebsite = true })
                                    ])
                        )
                }
                .sheet(isPresented: self.$presentation.isAddWebsite, content: {
                    Snapshotter() { result in
                        switch result {
                        case .success(let output):
                            // TODO: maybe show error to user?
                            try! self.controller.controller.createWebsite(.init(output)).get()
                        case .failure(let error):
                            // TODO: maybe show error to user?
                            break
                        }
                        self.presentation.isAddWebsite = false
                    }
                })
            }
        }
    }
}
