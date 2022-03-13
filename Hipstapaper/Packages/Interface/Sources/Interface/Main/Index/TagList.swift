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
    
    typealias Navigation = (AnyElementObserver<AnyTag>) -> Nav
    
    let controller: Controller
    let navigation: Navigation
        
    @SceneTag private var selectedTag
    @StateObject var data = NilBox<AnyListObserver<AnyRandomAccessCollection<AnyElementObserver<AnyTag>>>>()
    @EnvironmentObject private var errorQ: ErrorQueue

    var body: some View {
        List {
            Section(header: STZ.VIEW.TXT(Noun.readingList.rawValue)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                ForEach(Query.Filter.anyTag_allCases) { tag in
                    NavigationLink(destination: self.navigation(tag),
                                   tag: tag.value.uri,
                                   selection: self.$selectedTag)
                    {
                        TagRow(item: tag)
                            .environment(\.XPL_isSelected, self.selectedTag == tag.value.uri)
                    }
                }
            }
            Section(header: STZ.VIEW.TXT(Noun.tags.rawValue)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                ForEach(self.data.value?.data ?? .empty) { tag in
                    NavigationLink(destination: self.navigation(tag),
                                   tag: tag.value.uri,
                                   selection: self.$selectedTag)
                    {
                        TagRow(item: tag)
                            .environment(\.XPL_isSelected, self.selectedTag == tag.value.uri)
                    }
                    // FB9048743: Makes context menu work on macOS
                    .modifier(TagMenu(controller: self.controller, selection: tag))
                }
            }
        }
        .navigationTitle(Noun.tags.rawValue)
        .modifier(Force.SidebarStyle())
        .modifier(IndexToolbar(controller: self.controller))
        .onAppear { self.updateData() }
    }
        
    private func updateData() {
        guard self.data.value == nil else { return }
        let result = self.controller.readTags()
        self.data.value = result.value
        result.error.map {
            log.error($0)
            self.errorQ.queue.append($0)
        }
    }
}

#if DEBUG
struct TagList_Preview: PreviewProvider {
    static var previews: some View {
        TagList(controller: P_Controller(),
                navigation: { _ in STZ.VIEW.TXT("Swift Previews") })
    }
}
#endif
