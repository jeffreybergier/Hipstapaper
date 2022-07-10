//
//  Created by Jeffrey Bergier on 2022/07/03.
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
import V3Model
import V3Style
import V3Localize

internal struct FormToolbar: ViewModifier {
    
    @Nav private var nav
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    @Environment(\.dismiss) private var dismiss
    
    private let deletable: Bool
    
    internal init(deletable: Bool) {
        self.deletable = deletable
    }
    
    internal func body(content: Content) -> some View {
        content
            .navigationTitle(self.text.titleWebsite)
            .navigationBarTitleDisplayModeInline
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    self.itemErrors
                }
                ToolbarItem(placement: .confirmationAction) {
                    self.itemClose
                }
                if self.deletable {
                    ToolbarItem(placement: .cancellationAction) {
                        self.itemDelete
                    }
                }
            }
    }
    
    @ViewBuilder private var itemErrors: some View {
        if self.nav.errorQueue.isEmpty == false {
            self.style.error.button(self.text.error) {
                self.nav.isErrorList.isPresented = true
            }
            .modifier(ErrorList.popover)
        }
    }
    
    private var itemClose: some View {
        self.style.done.button(self.text.done,
                               style: .text)
        {
            self.dismiss()
        }
    }
    
    private var itemDelete: some View {
        self.style.deleteWebsite.button(self.text.delete,
                                        style: .text,
                                        role: .destructive)
        {
            // TODO: Add delete
        }
    }
}
