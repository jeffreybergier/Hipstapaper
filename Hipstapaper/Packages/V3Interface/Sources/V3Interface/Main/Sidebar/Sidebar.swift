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
import V3Store
import V3Model

extension View {
    func popover<C: Collection, V: View>(items: Binding<C>, @ViewBuilder content: @escaping (C) -> V) -> some View where C.Element: Identifiable {
        let newBinding: Binding<C?> = Binding {
            items.wrappedValue
        } set: {
            items.wrappedValue = $0!
        }
        return self.popover(item: newBinding, content: content)
    }
}

internal struct Sidebar: View {
    
    @Nav private var nav
    @TagsUser private var tagsUser
    @TagsSystem private var tagsSystem
    
    internal var body: some View {
        NavigationStack {
            List(selection: self.$nav.selectedTags) {
                Section("Reading List") {
                    ForEach(self.tagsSystem) { item in
                        NavigationLink(value: item.id) {
                            Text(item.id.rawValue).tag(item.id)
                        }
                    }
                }
                Section("Tags") {
                    ForEach(self.tagsUser) { item in
                        NavigationLink(value: item.id) {
                            Text(item.id.rawValue).tag(item.id)
                                .popover(item: self.$nav.sidebarNav.tagsEdit) { items in
                                    TagsEdit(items)
                                }
                        }
                    }
                }
            }
            .contextMenu(forSelectionType: Tag.Selection.Element.self) { items in
                Button {
                    self.nav.sidebarNav.tagsEdit = items
                } label: {
                    Label("Edit Tag(s)", systemImage: "tag")
                }
                Button(role: .destructive) {
                    // TODO: Hook up deletions
                } label: {
                    Label("Delete Tag(s)", systemImage: "tag")
                }
            }
            .navigationTitle("Tags")
            .toolbar {
                ToolbarItem(id: "sidebar.tag.add", placement: .primaryAction) {
                    Menu {
                        Button {
                            // TODO: Add tag to CD here
                            self.nav.sidebarNav.tagAdd = .init(rawValue: "coredata://testing123")
                        } label: {
                            Label("Add Tag", systemImage: "tag")
                        }
                        Button {
                            // TODO: Add tag to CD here
                            self.nav.sidebarNav.websiteAdd = .init(rawValue: "coredata://testing123")
                        } label: {
                            Label("Add Website", systemImage: "tag")
                        }
                    } label: {
                        Label("Add Tags and Websites", systemImage: "plus")
                    }
                    .popover(item: self.$nav.sidebarNav.tagAdd) { id in
                        TagsEdit([id])
                    }
                }
            }
        }
    }
}
