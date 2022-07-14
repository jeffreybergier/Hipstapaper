//
//  Created by Jeffrey Bergier on 2022/07/09.
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
import V3Style
import V3Localize

internal struct TagToolbar: ViewModifier {
    
    @Nav private var nav
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    @Environment(\.dismiss) private var dismiss
    
    internal func body(content: Content) -> some View {
        content
            .modifier(self.itemGeneric)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    self.itemErrors
                }
            }
    }
    
    private var itemGeneric: some ViewModifier {
        JSBToolbar(
            title: self.text.titleTag,
            done: self.text.done,
            doneAction: { self.dismiss() }
        )
    }

    @ViewBuilder private var itemErrors: some View {
        if self.nav.errorQueue.isEmpty == false {
            self.style.error.button(self.text.error) {
                self.nav.isErrorList.isPresented = true
            }
            .modifier(ErrorList.popover)
        }
    }
}

extension ViewModifier where Self == TagToolbar {
    internal static var toolbar: Self { .init() }
}