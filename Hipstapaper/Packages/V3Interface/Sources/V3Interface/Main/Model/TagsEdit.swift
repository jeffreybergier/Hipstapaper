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

internal struct TagsEdit: View {
    
    @Nav private var nav
    @TagUserListQuery(defaultListAll: false) private var data
    
    @V3Localize.TagsEdit private var text
    @Environment(\.dismiss) private var dismiss
    
    internal let selection: Tag.Selection
    
    internal init(_ selection: Tag.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        ErrorResponder(presenter: self.$nav.sidebar.isTagsEdit,
                       storage: self.$nav.errorQueue)
        {
            NavigationStack {
                Form {
                    self.$data.view {
                        ForEach($0) { item in
                            TextField(self.text.placeholderName,
                                      text: item.name.compactMap())
                        }
                    } onEmpty: {
                        TextField(self.text.placeholderName,
                                  text: Binding.constant(""))
                    }
                }
                .onLoadChange(of: self.selection) {
                    _data.setQuery($0)
                }
                .modifier(self.toolbar)
            }
        } onConfirmation: {
            // TODO: Do something with this confirmation
            print($0)
            print("")
        }
        .frame(idealWidth: 320, minHeight: 320)
    }
    
    private var toolbar: some ViewModifier {
        JSBToolbar(title: self.text.title,
                   done: self.text.toolbarDone)
        {
            self.dismiss()
        }
    }
}

internal struct TagsEditPresentation: ViewModifier {
    
    @Binding private var identifiers: Tag.Selection
    
    internal init(_ identifiers: Binding<Tag.Selection>) {
        _identifiers = identifiers
    }
    
    internal func body(content: Content) -> some View {
        content.popover(items: self.$identifiers)
        { selection in
            TagsEdit(selection)
                .presentationDetents([.medium, .large])
        }
    }
}
