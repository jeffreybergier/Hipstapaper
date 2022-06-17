//
//  Created by Jeffrey Bergier on 2022/06/17.
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

internal struct TagsEdit: View {
    
    internal let selection: Tag.Selection
    internal let data: [Tag.Selection.Element]
        
    init(_ selection: Tag.Selection) {
        self.selection = selection
        self.data = Array(selection)
    }
    
    internal var body: some View {
        NavigationStack {
            List(self.data) { ident in
                Text(ident.rawValue)
            }
            .navigationTitle("Edit Tag(s)")
        }
        .frame(idealWidth: 320, minHeight: 320)

    }
}

internal struct TagsEditPresentation: ViewModifier {
    @Binding private var identifiers: Tag.Selection
    internal init(_ identifiers: Binding<Tag.Selection>) {
        _identifiers = identifiers
    }
    internal func body(content: Content) -> some View {
        content.popover(items: self.$identifiers) {
            TagsEdit($0)
                .presentationDetents([.medium])
        }
    }
}

internal struct TagAddPresentation: ViewModifier {
    @Binding private var identifier: Tag.Selection.Element?
    internal init(_ identifier: Binding<Tag.Selection.Element?>) {
        _identifier = identifier
    }
    internal func body(content: Content) -> some View {
        content.popover(item: self.$identifier) {
            TagsEdit([$0])
                .presentationDetents([.medium])
        }
    }
}

extension ViewModifier where Self == TagsEditPresentation {
    internal static func tagsEditPopover(_ identifiers: Binding<Tag.Selection>) -> Self { Self.init(identifiers) }
}

extension ViewModifier where Self == TagAddPresentation {
    internal static func tagAddPopover(_ identifier: Binding<Tag.Selection.Element?>) -> Self { Self.init(identifier) }
}
