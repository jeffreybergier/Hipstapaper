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
import V3Store
import V3Style
import V3Localize

internal struct Sidebar: View {
    
    @Nav private var nav
    @V3Style.Sidebar private var style
    @V3Localize.Sidebar private var text
    
    @TagSystemListQuery private var tagsSystem
    @FAST_TagUserListQuery private var tagsUser
                
    internal var body: some View {
        NavigationStack {
            List(selection: self.$nav.sidebar.selectedTag) {
                Section(self.text.sectionTitleTagsSystem) {
                    ForEach(self.tagsSystem, id: \.id) { item in
                        NavigationLink(value: item.id) {
                            SidebarSystemRow(item.id.kind)
                        }
                    }
                }
                Section(self.text.sectionTitleTagsUser) {
                    self.tagsUser.view {
                        ForEach($0, id: \.self) { identifier in
                            NavigationLink(value: identifier) {
                                SidebarUserRow(identifier)
                            }
                        }
                    } onEmpty: {
                        self.style.noTags.label(self.text.noTags)
                            .modifier(self.style.titleText)
                            .modifier(self.style.disableFake)
                    }
                }
            }
            .modifier(SidebarMenu())
            .modifier(SidebarToolbar())
            .navigationTitle(self.text.navigationTitle)
        }
    }
}
