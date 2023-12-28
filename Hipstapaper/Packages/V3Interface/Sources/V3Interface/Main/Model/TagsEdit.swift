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
    @HACK_macOS_Style private var hack_style
    
    @Environment(\.dismiss) private var dismiss
    
    internal let selection: Tag.Selection
    
    internal init(_ selection: Tag.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        NavigationStack {
            JSBForm {
                ForEach(Array(self.selection)) {
                    TagsEditRow($0)
                }
            }
            .modifier(self.hack_style.formStyle)
            .modifier(TagsEditToolbar(self.selection))
        }
        .modifier(
            ErrorStorage.Presenter(
                isAlreadyPresenting: self.nav.sidebar.isTagsEdit.isPresenting,
                toPresent: self.$nav.sidebar.isTagsEdit.isError,
                router: errorRouter(_:)
            )
        )
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
    
    @TagQuery private var query
    
    @V3Style.TagsEdit    private var style
    @V3Localize.TagsEdit private var text
    @HACK_macOS_Style    private var hack_style
    
    private let identifier: Tag.Identifier
    
    internal init(_ identifier: Tag.Identifier) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        self.$query.view {
            TextField(self.text.placeholderName,
                      text: $0.name.compactMap())
            .modifier(self.hack_style.formTextFieldStyle)
        } onNIL: {
            self.style.disabled
                .action(text: self.text.noTagSelected)
                .label
        }
        .onChange(of: self.identifier, initial: true) { _, newValue in
            self.query.identifier = newValue
        }
    }
}

internal struct TagsEditToolbar: ViewModifier {
    
    @Controller   private var controller
    @ErrorStorage private var errors
    @BulkActions  private var actions
    
    @V3Localize.TagsEdit private var text
    
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
            let error = DeleteTagConfirmationError(self.selection) { selection in
                switch self.controller.delete(selection) {
                case .success:
                    self.dismiss()
                case .failure(let error):
                    self.errors.append(error)
                }
            }
            self.errors.append(error)
        }
    }
}
