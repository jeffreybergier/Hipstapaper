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
import V3Style

extension ViewModifier where Self == SidebarToolbar {
    internal static var sidebarToolbar: Self { Self.init() }
}

internal struct SidebarToolbar: ViewModifier {
    
    @Nav private var nav
    @V3Style.Sidebar private var style
    
    internal func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(id: "sidebar.tag.add", placement: .primaryAction) {
                Menu {
                    self.style.toolbarTagAdd.button("Add Tag") {
                        // TODO: Add tag to CD here
                        self.nav.sidebarNav.tagAdd = .init(rawValue: "coredata://testing123")
                    }
                    self.style.toolbarWebsiteAdd.button("Add Website") {
                        self.nav.sidebarNav.websiteAdd = .init(rawValue: "coredata://testing123")
                    }
                } label: {
                    self.style.toolbarAdd.label("Add Websites and Tags")
                }
                .modifier(.tagAddPopover(self.$nav.sidebarNav.tagAdd))
                .popover(item: self.$nav.sidebarNav.websiteAdd) { id in
                    // TODO: Add website screen
                    Text("Add a website")
                }
            }
        }
    }
}
