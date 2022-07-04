//
//  Created by Jeffrey Bergier on 2022/06/25.
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
import V3Localize
import V3Model
import V3Store

internal struct TagApply: View {
    
    private let selection: Website.Selection
    
    @TagApplyQuery private var data
    @V3Localize.TagApply private var text
    @Environment(\.dismiss) private var dismiss
    
    internal init(_ selection: Website.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        NavigationStack {
            Form {
                ForEach(self.$data) { item in
                    // TODO: Fix JSBToggle to suppport NIL strings
                    Toggle(item.wrappedValue.tag.name ?? self.text.untitled,
                           isOn: item.status.boolValue.flipped)
                }
            }
            .modifier(self.toolbar)
        }
        .frame(idealWidth: 320, minHeight: 320)
        .onLoadChange(of: self.selection) {
            _data.selection = $0
        }
    }
    
    private var toolbar: some ViewModifier {
        JSBToolbar(title: self.text.title,
                   done: self.text.done,
                   doneAction: { self.dismiss() })
    }
}

internal struct TagApplyPresentation: ViewModifier {
    @Nav private var nav
    internal func body(content: Content) -> some View {
        content.popover(items: self.$nav.detail.isTagApply) { selection in
            TagApply(selection)
        }
    }
}

extension ViewModifier where Self == TagApplyPresentation {
    internal static var tagApplyPopover: Self { Self.init() }
}
