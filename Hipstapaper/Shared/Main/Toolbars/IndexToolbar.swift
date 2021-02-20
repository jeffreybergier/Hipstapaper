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
import Umbrella
import Datum
import Localize
import Stylize
import Snapshot

struct IndexToolbar: ViewModifier {
    
    let controller: Controller
    @Binding var selection: TH.Selection?
    
    func body(content: Content) -> some View {
        return ZStack(alignment: .topTrailing) {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .modifier(AddTagPresentable(controller: self.controller))
            Color.clear.frame(width: 1, height: 1)
                .modifier(AddWebsitePresentable(controller: self.controller))
            Color.clear.frame(width: 1, height: 1)
                .modifier(AddChoicePresentable())
            
            #if os(macOS)
            content.modifier(IndexToolbar_macOS(controller: self.controller,
                                                selection: self.$selection))
            #else
            content.modifier(IndexToolbar_iOS())
            #endif
        }
    }
}

#if os(macOS)
struct IndexToolbar_macOS: ViewModifier {
    
    let controller: Controller
    @Binding var selection: TH.Selection?
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var errorQ: ErrorQueue
    
    func body(content: Content) -> some View {
        content.toolbar(id: "Index") {
            ToolbarItem(id: "Index.Sync") {
                STZ.TB.Sync(self.controller.syncProgress)
            }
            ToolbarItem(id: "Index.FlexibleSpace") {
                Spacer()
            }
            ToolbarItem(id: "Index.DeleteTag", placement: .automatic) {
                STZ.TB.DeleteTag_Minus.toolbar(isEnabled: TH.canDelete(self.selection),
                                               action: { self.errorQ.queue.append(DeleteError.tag({
                                                self.errorQ.queue.append(DeleteError.tag({
                                                    TH.delete(self.selection, self.controller, self.errorQ)
                                                }))
                                               }))})
            }
            ToolbarItem(id: "Index.AddChoice", placement: .primaryAction) {
                STZ.TB.AddChoice.toolbar(action: { self.modalPresentation.value = .addChoose })
            }
        }
    }
}
#else
struct IndexToolbar_iOS: ViewModifier {
    
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.toolbar(id: "Index") {
            ToolbarItem(id: "iOS.AddChoice", placement: .primaryAction) {
                STZ.TB.AddChoice.toolbar() {
                    self.modalPresentation.value = .addChoose
                }
            }
        }
    }
}
#endif
