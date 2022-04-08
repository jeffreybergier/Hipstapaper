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

struct Form: View {
    
    @Localize private var text
    @Binding var website: Website
    
    var body: some View {
        VStack {
            STZ.VIEW.TXTFLD.WebTitle.textfield(self.$website.title, bundle: self.text)
            HStack {
                STZ.VIEW.TXTFLD.WebURL.textfield(self.$website.originalURL, bundle: self.text)
                if true {
                    STZ.TB.JSActive.button_iconOnly(bundle: self.text) {
                        // TODO: Fix
                    }
                } else {
                    STZ.TB.JSInactive.button_iconOnly(bundle: self.text) {
                        // TODO: Fix
                    }
                }
                STZ.BTN.Go.button(doneStyle: true,
                                  isEnabled: true,
                                  bundle: self.text)
                {
                    // TODO: Fix
                }
            }
            STZ.VIEW.TXTFLD.WebURL.textfield(self.$website.resolvedURL, bundle: self.text)
                .disabled(true)
        }
    }
}
