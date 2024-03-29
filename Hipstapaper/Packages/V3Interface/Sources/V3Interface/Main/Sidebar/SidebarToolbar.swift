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
import V3Localize
import V3Style

#if DEBUG
import Umbrella
#endif


internal struct SidebarToolbar: ViewModifier {
    
    @Navigation private var nav
    @BulkActions private var state
    
    @V3Style.Sidebar private var style
    @V3Localize.Sidebar private var text
    
    internal func body(content: Content) -> some View {
        content
             // TODO: Not sure why the changes in sidebar toggle in iOS 17/macOS 14 break my toolbars
            .toolbar(removing: .sidebarToggle)
            .toolbar(id: .barSidebar) {
                ToolbarItem(id: .sidebarToolbarMultiAdd, placement: .primaryAction) {
                    Menu {
                        self.style.toolbar.action(text: self.text.toolbarAddTag).button {
                            self.state.push.tagAdd = true
                        }
                        self.style.toolbar.action(text: self.text.toolbarAddWebsite).button {
                            self.state.push.websiteAdd = true
                        }
                        self.DEBUG_addFakeData
                    } label: {
                        self.style.toolbar.action(text: self.text.toolbarAddGeneric).label
                    }
                    .modifier(TagsEditPresentation(self.$nav.sidebar.isTagsEdit.isPresented))
                }
            }
    }
    
#if DEBUG
    @Controller private var controller
    @ErrorStorage private var errors
    @ViewBuilder private var DEBUG_addFakeData: some View {
        Button("DEBUG: Add Fake Data") {
            guard let error = _controller.createFakeData().error else { return }
            self.errors.append(error)
        }
        Button("DEBUG: Delete All Data") {
            guard let error = _controller.deleteAllData().error else { return }
            self.errors.append(error)
        }
    }
#else
    @ViewBuilder private var DEBUG_addFakeData: some View {
        EmptyView()
    }
#endif
}

extension String {
    fileprivate static let barSidebar             = "barSidebar"
    fileprivate static let sidebarToolbarMultiAdd = "sidebarToolbarMultiAdd"
}
