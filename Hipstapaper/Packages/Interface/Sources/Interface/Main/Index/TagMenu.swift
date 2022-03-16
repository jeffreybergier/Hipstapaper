//
//  Created by Jeffrey Bergier on 2021/02/06.
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
import Datum2
import Umbrella
import Stylize
import Localize

struct TagMenu: ViewModifier {
    
    let controller: Controller
    @State var selection: TH.Selection
    @ErrorQueue private var errorQ
    @StateObject private var modalPresentation = ModalPresentation.Wrap()
    
    func body(content: Content) -> some View {
        ZStack {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .modifier(TagNamePickerPresentable())
            content.contextMenu {
                STZ.TB.EditTag.context() {
                    self.modalPresentation.value = .tagName(self.selection)
                }
                STZ.TB.DeleteTag_Trash.context() {
                    let error = DeleteError.tag {
                        TH.delete(self.selection, self.controller, self._errorQ.environment)
                    }
                    self.errorQ = error
                }
            }
        }
        .environmentObject(self.modalPresentation)
    }
}
