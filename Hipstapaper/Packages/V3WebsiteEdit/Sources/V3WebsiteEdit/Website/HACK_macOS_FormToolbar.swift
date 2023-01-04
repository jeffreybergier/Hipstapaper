//
//  Created by Jeffrey Bergier on 2022/12/25.
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
import V3Errors

internal struct HACK_macOS_FormToolbar: ViewModifier {
    
    @Navigation private var nav
    @Errors private var errorQueue
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    @HACK_macOS_Style private var hack_style
    
    @Dismiss private var dismiss
    @Environment(\.errorResponder) private var errorResponder
    
    private let deletableSelection: Website.Selection
    
    internal init(_ deletableSelection: Website.Selection) {
        self.deletableSelection = deletableSelection
    }
    
    internal func body(content: Content) -> some View {
        VStack {
            ZStack {
                HStack {
                    self.style.toolbarDelete
                        .action(text: self.text.delete)
                        .button(items: self.deletableSelection)
                    {
                        self.errorResponder(DeleteRequestError.website($0))
                    }
                    if self.errorQueue.isEmpty == false {
                        self.style.HACK_macOS_toolbar
                            .action(text: self.text.error)
                            .button(items: self.errorQueue)
                        { _ in
                            self.nav.isErrorList.isPresented = true
                        }
                        .modifier(ErrorListPopover())
                    }
                    Spacer()
                    self.style.toolbarDone
                        .action(text: self.text.done)
                        .button(action: self.dismiss)
                }
                self.style.toolbarDone
                    .action(text: .init(title: self.text.titleWebsite))
                    .label
            }
        }
        .modifier(self.hack_style.toolbarPadding)
        content
    }
}
