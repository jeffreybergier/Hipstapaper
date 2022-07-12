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

internal struct TagsEdit: View {
    
    // TODO: Localize
    @TagUserListQuery(defaultListAll: false) private var data
    @Environment(\.dismiss) private var dismiss
    
    internal let selection: Tag.Selection
    
    internal init(_ selection: Tag.Selection) {
        self.selection = selection
    }
        
    internal var body: some View {
        NavigationStack {
            Form {
                if self.data.isEmpty {
                    // Show dummy field while core data loads
                    TextField("Tag Name", text: Binding.constant(""))
                } else {
                    ForEach(self.$data) { item in
                        TextField("Tag Name", text: item.name.compactMap())
                    }
                }
            }
            .modifier(self.toolbar)
            .onLoadChange(of: self.selection) {
                _data.setQuery($0)
            }
        }
        .frame(idealWidth: 320, minHeight: 320)
    }
    
    private var toolbar: some ViewModifier {
        JSBToolbar(title: "Edit Tag(s)",
                   done: "Done")
        {
            self.dismiss()
        }
    }
}

internal struct TagsEditPresentation: ViewModifier {
    
    @Nav private var nav
    @Binding private var identifiers: Tag.Selection
    
    internal init(_ identifiers: Binding<Tag.Selection>) {
        _identifiers = identifiers
    }
    
    internal func body(content: Content) -> some View {
        content.popover(items: self.$identifiers)
        { selection in
            ErrorResponder(presenter: self.$nav.sidebar.isTagsEdit,
                           storage: self.$nav.errorQueue)
            {
                TagsEdit(selection)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

extension ViewModifier where Self == TagsEditPresentation {
    internal static func tagsEditPopover(_ identifiers: Binding<Tag.Selection>) -> Self { Self.init(identifiers) }
}
