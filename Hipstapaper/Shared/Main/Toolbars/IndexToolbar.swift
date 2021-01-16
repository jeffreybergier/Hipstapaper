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
    @EnvironmentObject private var presentation: ModalPresentation.Wrap

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
                .modifier(AddTagPresentable(controller: self.controller.controller))
            Color.clear.frame(width: 1, height: 1)
                .modifier(AddWebsitePresentable(controller: self.controller.controller))
            Color.clear.frame(width: 1, height: 1)
                .modifier(AddChoicePresentable())
            
            #if os(macOS)
            content.toolbar(id: "Index") {
                ToolbarItem(id: "Index.Delete", placement: .destructiveAction) {
                    STZ.TB.DeleteTag.toolbar(
                        isDisabled: {
                            guard let tag = self.controller.selection else { return true }
                            return tag.value.wrappedValue as? Query.Archived != nil
                        }(),
                        action: {
                            // Delete
                            guard let tag = self.controller.selection else { return }
                            try! self.controller.controller.delete(tag).get()
                        })
                }
                ToolbarItem(id: "Index.Add", placement: .primaryAction) {
                    STZ.TB.AddChoice.toolbar(action: { self.presentation.value = .addChoose })
                }
            }
            #else
            if self.editMode?.wrappedValue == .inactive {
                content.toolbar(id: "Index") {
                    ToolbarItem(id: "Index.Edit", placement: .bottomBar) {
                        EditButton()
                    }
                    ToolbarItem(id: "Index.Add", placement: .primaryAction) {
                        STZ.TB.AddChoice.toolbar(action: { self.presentation.value = .addChoose  })
                    }
                }
            } else {
                content.toolbar(id: "Index") {
                    ToolbarItem(id: "Index.Edit", placement: .bottomBar) {
                        EditButton()
                    }
                    ToolbarItem(id: "Index.Delete", placement: .bottomBar) {
                        STZ.TB.DeleteTag.toolbar(isDisabled: {
                            guard let tag = self.controller.selection else { return true }
                            return tag.value.wrappedValue as? Query.Archived != nil
                        }(),
                        action: {
                            // Delete
                            guard let tag = self.controller.selection else { return }
                            try! self.controller.controller.delete(tag).get()
                        })
                    }
                    ToolbarItem(id: "Index.AddTag", placement: .bottomBar) {
                        STZ.TB.AddTag.toolbar(action: { self.presentation.value = .addTag })
                    }
                }
            }
            #endif
        }
    }
}
