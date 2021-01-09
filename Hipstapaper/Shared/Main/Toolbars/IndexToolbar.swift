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
    
    @ObservedObject var controller: TagController
    @State var presentation = IndexToolbarPresentation.Wrap()
    
    #if os(macOS)
    /// Source of popover
    private let alignment: Alignment = .topTrailing
    #else
    @Environment(\.editMode) var editMode
    private var alignment: Alignment {
        switch self.editMode?.wrappedValue ?? .inactive {
        case .active:
            return .bottomTrailing
        case .inactive, .transient:
            fallthrough
        @unknown default:
            return .topTrailing
        }
    }
    #endif
    
    func body(content: Content) -> some View {
        return ZStack(alignment: self.alignment) {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$presentation.isAddTag) {
                    AddTag(
                        cancel: { self.presentation.value = .none },
                        save: {
                            let result = self.controller.controller.createTag(name: $0)
                            switch result {
                            case .success:
                                self.presentation.value = .none
                            case .failure(let error):
                                // TODO: Do something with this error
                                break
                            }
                        }
                    )
                }
            
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .sheet(isPresented: self.$presentation.isAddWebsite) {
                    return Snapshotter(.init(doneAction: { result in
                        switch result {
                        case .success(let output):
                            // TODO: maybe show error to user?
                            _ = try! self.controller.controller.createWebsite(.init(output)).get()
                        case .failure(let error):
                            // TODO: maybe show error to user?
                            break
                        }
                        self.presentation.value = .none
                    }))
                }
            
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .modifier(ActionSheet(
                    isPresented: self.$presentation.isAddChoose,
                    title: Phrase.AddChoice,
                    buttons: [
                        .init(title: Verb.AddTag) {
                            self.presentation.value = .none
                            // TODO: Remove this hack when possible
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.presentation.value = .addTag
                            }
                        },
                        .init(title: Verb.AddWebsite) {
                            self.presentation.value = .none
                            // TODO: Remove this hack when possible
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.presentation.value = .addWebsite
                            }
                        }
                    ]
                ))
            
            #if os(macOS)
            content.toolbar(id: "Index") {
                ToolbarItem(id: "Index.Delete", placement: .destructiveAction) {
                    ButtonToolbar(systemName: "minus",
                                  accessibilityLabel: Verb.DeleteTag)
                    {
                        // Delete
                        guard let tag = self.controller.selection else { return }
                        try! self.controller.controller.delete(tag).get()
                    }
                    .disabled({
                        guard let tag = self.controller.selection else { return true }
                        return tag.value.wrappedValue as? Query.Archived != nil
                    }())
                }
                ToolbarItem(id: "Index.Add", placement: .primaryAction) {
                    ButtonToolbar(systemName: "plus",
                                  accessibilityLabel: Verb.AddTag,
                                  action: { self.presentation.value = .addChoose })
                }
            }
            #else
            if self.editMode?.wrappedValue == .inactive {
                content.toolbar(id: "Index") {
                    ToolbarItem(id: "Index.Edit", placement: .bottomBar) {
                        EditButton()
                    }
                    ToolbarItem(id: "Index.Add", placement: .primaryAction) {
                        ButtonToolbar(systemName: "plus",
                                      accessibilityLabel: Verb.AddTag,
                                      action: { self.presentation.value = .addChoose })
                    }
                }
            } else {
                content.toolbar(id: "Index") {
                    ToolbarItem(id: "Index.Edit", placement: .bottomBar) {
                        EditButton()
                    }
                    ToolbarItem(id: "Index.Delete", placement: .bottomBar) {
                        ButtonToolbar(systemName: "minus",
                                      accessibilityLabel: Verb.DeleteTag)
                        {
                            // Delete
                            guard let tag = self.controller.selection else { return }
                            try! self.controller.controller.delete(tag).get()
                        }
                        .disabled({
                            guard let tag = self.controller.selection else { return true }
                            return tag.value.wrappedValue as? Query.Archived != nil
                        }())
                    }
                    ToolbarItem(id: "Index.Add", placement: .bottomBar) {
                        ButtonToolbar(systemName: "plus",
                                      accessibilityLabel: Verb.AddTag,
                                      action: { self.presentation.value = .addTag })
                    }
                }
            }
            #endif
        }
    }
}
