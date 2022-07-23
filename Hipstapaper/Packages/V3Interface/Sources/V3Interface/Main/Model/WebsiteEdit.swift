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
import V3Model
import V3WebsiteEdit

internal struct TagApply: ViewModifier {
    @Binding private var selection: Website.Selection
    internal init(_ selection: Binding<Website.Selection>) {
        _selection = selection
    }
    internal func body(content: Content) -> some View {
        content.popover(items: self.$selection) { selection in
            V3WebsiteEdit.WebsiteEdit(selection: selection, start: .tag)
        }
    }
}

extension ViewModifier where Self == TagApply {
    internal static func popover(_ selection: Binding<Website.Selection>) -> Self { Self.init(selection) }
}

internal struct WebsiteEdit: ViewModifier {
    @Binding private var selection: Website.Selection
    internal init(_ selection: Binding<Website.Selection>) {
        _selection = selection
    }
    internal func body(content: Content) -> some View {
        content.sheet(items: self.$selection) { selection in
            V3WebsiteEdit.WebsiteEdit(selection: selection, start: .website)
        }
    }
}

extension ViewModifier where Self == WebsiteEdit {
    internal static func sheet(_ selection: Binding<Website.Selection>) -> Self { Self.init(selection) }
}
