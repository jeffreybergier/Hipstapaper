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
import V3Errors

public struct WebsiteEdit: View {
    
    private let selection: Website.Selection
    
    @StateObject private var nav = Nav.newEnvironment()
    
    public init(_ selection: Website.Selection) {
        self.selection = selection
    }
    
    public var body: some View {
        _WebsiteEdit(self.selection)
            .environmentObject(self.nav)
    }
    
}

fileprivate struct _WebsiteEdit: View {
    
    @Nav private var nav
    private let selection: Website.Selection

    internal init(_ selection: Website.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        ErrorResponder(presenter: self.$nav,
                       storage: self.$nav.errorQueue)
        {
            NavigationStack {
                Group {
                    switch self.selection.count {
                    case 0:
                        EmptyState()
                    case 1:
                        FormSingle(self.selection.first!)
                    default:
                        FormMulti(self.selection)
                    }
                }
                .modifier(self.toolbar)
            }
        }
    }
    
    private var toolbar: some ViewModifier {
        Toolbar(self.selection)
    }
}

internal struct EmptyState: View {
    internal var body: some View {
        Label("Nothing Selected", systemImage: "rectangle.on.rectangle.slash")
    }
}
