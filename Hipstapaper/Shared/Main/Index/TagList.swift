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
    @StateObject var viewModel: NilBox<AnyTagViewModel> = .init()
    @SceneTag private var selectedTag
    @EnvironmentObject private var errorQ: ErrorQueue

    var body: some View {
        List(selection: self.$selection) {
            Section(header: STZ.VIEW.TXT(Noun.readingList.rawValue)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                ForEach(self.viewModel.value?.fixed ?? .empty, id: \.tag) { output in
                    NavigationLink(destination: self.navigation(output.tag),
                                   isActive: output.binding)
                    {
                        TagRow(item: output.tag)
                            .environment(\.XPL_isSelected, self.selection == output.tag)
                    }
                }
            }
            Section(header: STZ.VIEW.TXT(Noun.tags.rawValue)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                ForEach(self.viewModel.value?.data ?? .empty, id: \.tag) { output in
                    NavigationLink(destination: self.navigation(output.tag),
                                   isActive: output.binding)
                    {
                        TagRow(item: output.tag)
                            .environment(\.XPL_isSelected, self.selection == output.tag)
                    }
                }
            }
        }
        .navigationTitle(Noun.tags.rawValue)
        .modifier(Force.SidebarStyle())
        .modifier(IndexToolbar(controller: self.controller,
                               selection: self.$selection))
        .onAppear { self.updateData() }
        .onDisappear { self.viewModel.value = nil }
    }
        
    private func updateData() {
        
        // TODO: With this backing store it works
        // But with @State or @SceneStorage one it does not work :(
        var selectedTag = self.selectedTag
        
        let result = self.controller.readTags()
        result.value?.getStorage = {
            return selectedTag
        }
        result.value?.setStorage = { newValue in
            selectedTag = newValue
        }
        self.viewModel.value = result.value
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
