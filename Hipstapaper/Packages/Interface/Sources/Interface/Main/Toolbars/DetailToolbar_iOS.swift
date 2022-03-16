//
//  Created by Jeffrey Bergier on 2021/01/01.
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

#if os(iOS)

import SwiftUI
import Umbrella
import Stylize
import Datum2

extension DetailToolbar {
    enum iOS { }
}

extension DetailToolbar.iOS {
    struct Shared: ViewModifier {
        
        let controller: Controller
        @Binding var selection: WH.Selection
        @Binding var popoverAlignment: Alignment
        
        @Environment(\.editMode) private var editMode
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
        @ViewBuilder func body(content: Content) -> some View {
            switch (self.horizontalSizeClass?.isCompact ?? true,
                    self.editMode?.isEditing ?? false)
            {
            case (true, true): // iPhone editing
                content.modifier(iPhoneEdit(controller: self.controller,
                                            selection: self.$selection,
                                            popoverAlignment: self.$popoverAlignment))
            case (true, false): // iPhone not editing
                content.modifier(iPhone(popoverAlignment: self.$popoverAlignment,
                                        syncProgress: self.controller.syncProgress))
            case (false, true): // iPad editing
                content.modifier(iPadEdit(controller: self.controller,
                                          selection: self.$selection,
                                          popoverAlignment: self.$popoverAlignment))
            case (false, false): // iPad not editing
                content.modifier(iPad(popoverAlignment: self.$popoverAlignment,
                                      syncProgress: self.controller.syncProgress))
            }
        }
    }
}

#endif
