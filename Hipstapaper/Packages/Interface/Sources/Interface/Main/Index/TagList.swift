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
    
    typealias Navigation = (TagListSelection) -> Nav
    let navigation: Navigation

    @Localize private var text
    @TagListQuery private var data
    @QueryProperty private var query
    @ControllerProperty private var controller
    
    @ErrorQueue private var errorQ
    @TagListSelectionProperty private var selectedTag
    @EnvironmentObject private var presentation: ModalPresentation.Wrap

    var body: some View {
        List {
            Section {
                ForEach(NotATag.allCases) { notATag in
                    NavigationLink(destination: self.navigation(.notATag(notATag)),
                                   tag: TagListSelection.notATag(notATag),
                                   selection: self.$selectedTag)
                    {
                        NotATagRow(item: notATag)
                            .environment(
                                \.XPL_isSelected,
                                 self.selectedTag == .notATag(notATag)
                            )
                    }
                }
            } header: {
                STZ.TB.AddWebsite.button_sidebar(bundle: self.text) {
                    // TODO: Remove this hack when possible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        switch self.controller.createWebsite(nil) {
                        case .success(let website):
                            self.presentation.value = .editWebsite(.add, [website])
                        case .failure(let error):
                            self.errorQ = error
                        }
                    }
                }
            }
            Section {
                ForEach(self.data) { tag in
                    NavigationLink(destination: self.navigation(.tag(tag)),
                                   tag: TagListSelection.tag(tag),
                                   selection: self.$selectedTag)
                    {
                        TagRow(item: tag)
                            .environment(
                                \.XPL_isSelected,
                                 self.selectedTag == .tag(tag)
                            )
                    }
                    // FB9048743: Makes context menu work on macOS
                    .modifier(TagMenu(selection: tag.uuid))
                }
            } header: {
                STZ.TB.AddTag.button_sidebar(bundle: self.text) {
                    // TODO: Remove this hack when possible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        switch self.controller.createTag() {
                        case .success(let id):
                            self.presentation.value = .tagName(id)
                        case .failure(let error):
                            self.errorQ = error
                        }
                    }
                }
            }
        }
        .navigationTitle(Noun.tags.loc(self.text))
        .modifier(Force.SidebarStyle())
        .modifier(IndexToolbar())
    }
}
