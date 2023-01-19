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
import V3Store
import V3Model
import V3Style
import V3Localize
import V3Errors

internal struct FormToolbar: ViewModifier {
    
    @Navigation   private var nav
    @Controller   private var controller
    @ErrorStorage private var errors
    
    @V3Style.WebsiteEdit    private var style
    @V3Localize.WebsiteEdit private var text
    
    @Dismiss private var dismiss
        
    private let deletableSelection: Website.Selection
    
    internal init(_ deletableSelection: Website.Selection) {
        self.deletableSelection = deletableSelection
    }
    
    internal func body(content: Content) -> some View {
        content
            .modifier(JSBToolbar(title: self.text.titleWebsite,
                           done: self.text.done,
                           delete: self.text.delete,
                           doneAction: self.dismiss,
                           deleteAction: self.delete))
    }
    
    private func delete() {
        let error = DeleteWebsiteConfirmationError(self.deletableSelection)
        { selection in
            switch self.controller.delete(selection) {
            case .success:
                self.dismiss()
            case .failure(let error):
                self.errors.append(error)
            }
        }
        self.errors.append(error)
    }
}
