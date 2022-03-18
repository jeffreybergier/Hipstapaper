//
//  Created by Jeffrey Bergier on 2020/11/30.
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
import Datum2
import Localize
import Stylize

struct TagList<Nav: View>: View {
    
    typealias Navigation = (Tag.Ident) -> Nav
    let navigation: Navigation

    @TagListQuery private var data
    @QueryProperty private var query
    @ControllerProperty private var controller
    
    @SceneStorage("SelectedTag") private var selectedTag: Tag.Ident?

    var body: some View {
        List {
            Section(header: STZ.VIEW.TXT(Noun.readingList.rawValue)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                ForEach(Tag.Ident.specialTags) { tag in
                    NavigationLink(destination: self.navigation(tag),
                                   tag: tag,
                                   selection: self.$selectedTag)
                    {
                        SpecialTagRow(item: tag)
                            .environment(\.XPL_isSelected, self.selectedTag == tag)
                    }
                }
            }
            Section(header: STZ.VIEW.TXT(Noun.tags.rawValue)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                ForEach(self.data) { tag in
                    NavigationLink(destination: self.navigation(tag.uuid),
                                   tag: tag.uuid,
                                   selection: self.$selectedTag)
                    {
                        TagRow(item: tag)
                            .environment(\.XPL_isSelected, self.selectedTag == tag.uuid)
                    }
                    // FB9048743: Makes context menu work on macOS
                    .modifier(TagMenu(controller: self.controller, selection: tag.uuid))
                }
            }
        }
        .navigationTitle(Noun.tags.rawValue)
        .modifier(Force.SidebarStyle())
        .modifier(IndexToolbar(controller: self.controller))
    }
}
