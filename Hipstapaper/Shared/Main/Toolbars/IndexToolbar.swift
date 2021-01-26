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
    @State private var popoverAlignment: Alignment = .topTrailing
    
    func body(content: Content) -> some View {
        return ZStack(alignment: self.popoverAlignment) {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .modifier(AddTagPresentable(controller: self.controller.controller))
            Color.clear.frame(width: 1, height: 1)
                .modifier(AddWebsitePresentable(controller: self.controller.controller))
            Color.clear.frame(width: 1, height: 1)
                .modifier(AddChoicePresentable())
            
            #if os(macOS)
            content.modifier(IndexToolbar_macOS(controller: self.controller))
            #else
            content.modifier(IndexToolbar_iOS(controller: self.controller,
                                              popoverAlignment: self.$popoverAlignment))
            #endif
        }
    }
}

#if os(macOS)
struct IndexToolbar_macOS: ViewModifier {
    
    @ObservedObject var controller: TagController
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var errorQ: STZ.ERR.ViewModel
    
    func body(content: Content) -> some View {
        content.toolbar(id: "Index") {
            ToolbarItem(id: "macOS.DeleteTag", placement: .automatic) {
                STZ.TB.DeleteTag.toolbar(isEnabled: self.controller.canDelete(),
                                         action: { self.controller.delete(self.errorQ) })
            }
            ToolbarItem(id: "macOS.AddChoice", placement: .primaryAction) {
                STZ.TB.AddChoice.toolbar(action: { self.modalPresentation.value = .addChoose })
            }
        }
    }
}
#else
struct IndexToolbar_iOS: ViewModifier {
    
    @ObservedObject var controller: TagController
    @Binding var popoverAlignment: Alignment
    
    @Environment(\.editMode) private var editMode
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var errorQ: STZ.ERR.ViewModel
    
    func body(content: Content) -> some View {
        if self.editMode?.wrappedValue.isEditing == false {
            return AnyView(
                content.toolbar(id: "Index") {
                    ToolbarItem(id: "iOS.EditButton", placement: .primaryAction) {
                        EditButton()
                    }
                }
            )
        } else {
            return AnyView(
                content.toolbar(id: "Index") {
                    ToolbarItem(id: "iOS.FlexibleSpace", placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(id: "iOS.DeleteTag", placement: .bottomBar) {
                        STZ.TB.DeleteTag.toolbar(isEnabled: self.controller.canDelete(),
                                                 action: { self.controller.delete(self.errorQ) })
                    }
                    ToolbarItem(id: "iOS.Divider", placement: .bottomBar) {
                        Text("   ") // TODO: Remove when spacer is no longer needed
                    }
                    ToolbarItem(id: "iOS.AddChoice", placement: .bottomBar) {
                        STZ.TB.AddChoice.toolbar() {
                            self.popoverAlignment = .bottomTrailing
                            self.modalPresentation.value = .addChoose
                        }
                    }
                    ToolbarItem(id: "iOS.EditButton", placement: .primaryAction) {
                        EditButton()
                    }
                }
            )
        }
    }
}
#endif
