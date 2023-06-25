//
//  Created by Jeffrey Bergier on 2022/07/08.
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
import V3Errors
import V3Style
import V3Localize

internal struct FormParent: View {
    
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    
    @Navigation private var nav
    @StateObject private var webState = WebState.newEnvironment()
    
    private let selection: Website.Selection

    internal init(_ selection: Website.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        NavigationStack {
            JSBForm {
                self.selection.view { selection in
                    switch selection.count {
                    case 1:
                        FormSingle(selection.first!)
                            .environmentObject(self.webState)
                    default:
                        FormMulti(selection)
                    }
                } onEmpty: {
                    self.style.disabled.action(text: self.text.noWebsitesSelected).label
                }
            }
            .modifier(FormToolbar(self.selection))
            // .scrollDismissesKeyboard(.immediately) // TODO: Add back in
        }
    }
}

extension Binding where Value == Optional<URL> {
    // Used for mapping URL model properties to text fields
    internal func mirror(string: Binding<String>) -> Binding<String> {
        self.map {
            $0?.absoluteString ?? string.wrappedValue
        } set: {
            string.wrappedValue = $0
            return URL(string: $0)
        }
    }
}
