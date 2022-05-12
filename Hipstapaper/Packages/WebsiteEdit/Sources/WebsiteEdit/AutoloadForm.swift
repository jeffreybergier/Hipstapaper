//
//  Created by Jeffrey Bergier on 2022/04/08.
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
import Datum
import Localize
import Stylize

internal struct AutoloadForm: View {
    
    @Binding internal var website: Website
    @ObservedObject internal var control: Control
    
    @Localize private var text
    
    internal var body: some View {
        VStack {
            HStack {
                STZ.VIEW.TXTFLD.AutofillURL.textfield(self.$website.originalURL,
                                                      bundle: self.text)
                self.jsButton()
                self.goButton()
            }
            STZ.VIEW.TXTFLD.WebTitle.textfield(self.$website.title,
                                               bundle: self.text)
            STZ.VIEW.TXTFLD.FilledURL.textfield(self.$website.resolvedURL,
                                                bundle: self.text)
        }
    }
    
    @ViewBuilder private func jsButton() -> some View {
        if self.control.isJSEnabled {
            STZ.TB.JSActive.button_iconOnly(bundle: self.text) {
                self.control.isJSEnabled = false
            }
        } else {
            STZ.TB.JSInactive.button_iconOnly(bundle: self.text) {
                self.control.isJSEnabled = true
            }
        }
    }
    
    @ViewBuilder private func goButton() -> some View {
        if self.control.isLoading {
            STZ.BTN.Stop.button(doneStyle: false,
                                isEnabled: true,
                                bundle: self.text)
            {
                self.control.shouldLoad = false
            }
        } else {
            STZ.BTN.Go.button(doneStyle: true,
                              isEnabled: self.website.originalURL != nil,
                              bundle: self.text)
            {
                self.control.shouldLoad = true
            }
        }
    }
}
