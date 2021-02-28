//
//  Created by Jeffrey Bergier on 2020/12/05.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
