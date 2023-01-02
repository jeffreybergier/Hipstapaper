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
    @Localize   private var bundle
    @Controller private var controller
    @HACK_macOS_Style private var hack_style
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorResponder) private var errorResponder
    
    internal let selection: Tag.Selection
    
    internal init(_ selection: Tag.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        NavigationStack {
            Form {
                ForEach(Array(self.selection)) {
                    TagsEditRow($0)
                }
            }
            .modifier(self.hack_style.formStyle)
            .modifier(TagsEditToolbar(self.selection))
        }
        .modifier(ErrorMover(isPresenting: self.nav.sidebar.isTagsEdit.isPresenting,
                             toPresent: self.$nav.sidebar.isTagsEdit.isError))
        .modifier(ErrorPresenter(isError: self.$nav.sidebar.isTagsEdit.isError,
                                 localizeBundle: self.bundle,
                                 router: self.router(_:)))
    }
    
    private func router(_ input: CodableError) -> UserFacingError {
        ErrorRouter.route(input: input,
                          onSuccess: self.dismiss.callAsFunction,
                          onError: self.errorResponder,
                          controller: self.controller)
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
    @HACK_macOS_Style private var hack_style
    
    private let identifier: Tag.Identifier
    
    internal init(_ identifier: Tag.Identifier) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        self.$item.view {
            TextField(self.text.placeholderName, text: $0.name.compactMap())
                .modifier(self.hack_style.formTextFieldStyle)
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
    
    @BulkActions private var actions
    @V3Localize.TagsEdit private var text
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorResponder) private var errorResponder
    
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
            self.actions.push.tagDelete = self.selection
        }
    }
}
