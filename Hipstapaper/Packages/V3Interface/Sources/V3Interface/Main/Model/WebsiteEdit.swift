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
import V3WebsiteEdit

internal struct TagApply: ViewModifier {
    @Nav private var nav
    internal func body(content: Content) -> some View {
        content.popover(items: self.$nav.detail.isTagApply) { selection in
            V3WebsiteEdit.WebsiteEdit(selection: selection, start: .tag)
        }
    }
}

extension ViewModifier where Self == TagApply {
    internal static var popover: Self { Self.init() }
}

internal struct WebsiteEdit: ViewModifier {
    @Nav private var nav
    internal func body(content: Content) -> some View {
        content.sheet(items: self.$nav.detail.isWebsitesEdit.editing) { selection in
            V3WebsiteEdit.WebsiteEdit(selection: selection, start: .website)
        }
    }
}

extension ViewModifier where Self == WebsiteEdit {
    internal static var sheet: Self { Self.init() }
}
