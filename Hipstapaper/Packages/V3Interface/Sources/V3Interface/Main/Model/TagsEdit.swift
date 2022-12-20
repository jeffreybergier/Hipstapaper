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
import Umbrella
import V3Model
import V3Store
import V3Errors
import V3Localize
import V3Style

internal struct TagsEdit: View {
    
    @Navigation private var nav
    @Errors private var errorQueue
    @Environment(\.dismiss) private var dismiss
    
    internal let selection: Tag.Selection
    
    internal init(_ selection: Tag.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        ErrorResponder(toPresent: self.$nav.sidebar.isTagsEdit.isError,
                       storeErrors: self.nav.sidebar.isTagsEdit.isPresenting,
                       inStorage: self.$errorQueue)
        {
            NavigationStack {
                Form {
                    ForEach(Array(self.selection)) {
                        TagsEditRow($0)
                    }
                }
                .formStyle(.grouped)
                .modifier(TagsEditToolbar(self.selection))
            }
        } onConfirmation: {
            switch $0 {
            case .deleteWebsites:
                NSLog("Probably unexpected: \($0)")
                break
            case .deleteTags:
                self.dismiss()
            }
        }
    }
}

internal struct TagsEditPresentation: ViewModifier {
    
    @Binding private var identifiers: Tag.Selection
    @V3Style.TagsEdit private var style
    
    internal init(_ identifiers: Binding<Tag.Selection>) {
        _identifiers = identifiers
    }
    
    internal func body(content: Content) -> some View {
        content.popover(items: self.$identifiers)
        { selection in
            TagsEdit(selection)
                .modifier(self.style.popoverSize)
        }
    }
}

internal struct TagsEditRow: View {
    
    @TagUserQuery private var item
    @V3Style.TagsEdit private var style
    @V3Localize.TagsEdit private var text
    
    private let identifier: Tag.Identifier
    
    internal init(_ identifier: Tag.Identifier) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        self.$item.view {
            TextField(self.text.placeholderName, text: $0.name.compactMap())
                .if(.macOS) { $0.textFieldStyle(.roundedBorder) }
        } onNIL: {
            self.style.disabled
                .action(text: self.text.noTagSelected)
                .label
        }
        .onLoadChange(of: self.identifier) {
            _item.setIdentifier($0)
        }
    }
}

internal struct TagsEditToolbar: ViewModifier {
    
    @V3Localize.TagsEdit private var text
    
    @Environment(\.codableErrorResponder) private var errorResponder
    @Environment(\.dismiss) private var dismiss
    
    internal let selection: Tag.Selection
    
    internal init(_ selection: Tag.Selection) {
        self.selection = selection
    }
    
    internal func body(content: Content) -> some View {
        content.modifier(self.toolbar)
    }
    
    private var toolbar: some ViewModifier {
        JSBToolbar(title: self.text.title,
                   done: self.text.toolbarDone,
                   delete: self.text.toolbarDelete)
        {
            self.dismiss()
        } deleteAction: {
            self.errorResponder(DeleteTagError(self.selection).codableValue)
        }
    }
}
