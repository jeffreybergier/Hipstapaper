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
import XPList

struct WebsiteList: View {
    
    private let selectedTag: TagListSelection
    
    @State private var selection: WH.Selection = []
    @QueryProperty private var query
    @WebsiteListQuery private var data: AnyRandomAccessCollection<FAST_Website>
    @ControllerProperty private var controller
    
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var windowPresentation: WindowPresentation
    
    init(selection: TagListSelection, onInitQuery query: Query, controller: Controller) {
        self.selectedTag = selection
        _data = .init(query: query, tag: selection, controller: controller)
    }
    
    var body: some View {
        XPL2.List(data: self.data,
                  selection: self.$selection,
                  open: self.open,
                  menu: self.menu)
        { item in
            WebsiteRow(item: item)
        }
        .listStyle(PlainListStyle())
        .modifier(SyncIndicator(progress: self.controller.syncProgress))
        .modifier(WebsiteListTitle(selection: self.selectedTag))
        // TODO: Fix the choppy EditMode animation caused by overly complex toolbars
        .modifier(DetailToolbar.Shared(controller: self.controller,
                                       selection: self.$selection))
        // TODO: Uncomment this later
        .environment(\.toolbarFilterIsEnabled, self.selectedTag.identValue != nil)
    }
}

extension WebsiteList {
    private func open(_ items: WH.Selection) {
        if self.windowPresentation.features.contains([.bulkActivation, .multipleWindows]) {
            let validURLs = Set(items.compactMap({ $0.preferredURL }))
            self.windowPresentation.show(validURLs)
        } else {
            guard let validItem = items.first(where: { $0.preferredURL != nil }) else { return }
            self.modalPresentation.value = .browser(validItem.websiteValue)
        }
    }
    private func menu(_ items: WH.Selection) -> WebsiteMenu {
        WebsiteMenu(items, self.controller)
    }
}
