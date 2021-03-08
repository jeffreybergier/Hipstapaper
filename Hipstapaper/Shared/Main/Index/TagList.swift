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
import Datum
import Localize
import Stylize

struct TagList<Nav: View>: View {
    
    typealias Navigation = (AnyElementObserver<AnyTag>) -> Nav
    
    let controller: Controller
    let navigation: Navigation
    
    @State private var selection: TH.Selection?
    @State private var initialSelection = true
    
    @EnvironmentObject private var errorQ: ErrorQueue

    @StateObject var data: NilBox<AnyListObserver<AnyRandomAccessCollection<AnyElementObserver<AnyTag>>>> = .init()

    var body: some View {
        List(selection: self.$selection) {
            Section(header: STZ.VIEW.TXT(Noun.readingList.rawValue)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                let item0 = Query.Filter.anyTag_allCases[0]
                let item1 = Query.Filter.anyTag_allCases[1]
                NavigationLink(destination: self.navigation(item0),
                               isActive: self.$initialSelection)
                {
                    TagRow(item: item0)
                        .environment(\.XPL_isSelected, self.selection == item0)
                }
                NavigationLink(destination: self.navigation(item1)) {
                    TagRow(item: item1)
                        .environment(\.XPL_isSelected, self.selection == item1)
                }
            }
            Section(header: STZ.VIEW.TXT(Noun.tags.rawValue)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                ForEach(self.data.value?.data ?? .empty, id: \.self) { item in
                    NavigationLink(destination: self.navigation(item)) {
                        TagRow(item: item)
                            .environment(\.XPL_isSelected, self.selection == item)
                            .modifier(TagMenu(controller: self.controller, selection: item))
                    }
                }
            }
        }
        .navigationTitle(Noun.tags.rawValue)
        .modifier(Force.SidebarStyle())
        .modifier(IndexToolbar(controller: self.controller,
                               selection: self.$selection))
        .onAppear { self.updateData() }
        .onDisappear { self.data.value = nil }
    }
    
    private func updateData() {
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
