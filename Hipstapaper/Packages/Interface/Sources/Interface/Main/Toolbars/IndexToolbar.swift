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

struct IndexToolbar: ViewModifier {
        
    func body(content: Content) -> some View {
        return ZStack(alignment: .topTrailing) {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .modifier(TagNamePickerPresentable())
            Color.clear.frame(width: 1, height: 1)
                .modifier(AddWebsitePresentable())
            
            #if os(macOS)
            content.modifier(IndexToolbar_macOS())
            #else
            content.modifier(IndexToolbar_iOS())
            #endif
        }
    }
}

#if os(macOS)
struct IndexToolbar_macOS: ViewModifier {
    
    @ControllerProperty private var controller
    
    func body(content: Content) -> some View {
        // TODO: Is this sync thing real?
        content.toolbar(id: "Index") {
            ToolbarItem(id: "Index.Sync") {
                STZ.TB.Sync(self.controller.syncProgress)
            }
        }
    }
}
#else
struct IndexToolbar_iOS: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
#endif
