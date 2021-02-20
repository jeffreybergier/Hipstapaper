//
//  Created by Jeffrey Bergier on 2020/11/30.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import Umbrella
import Datum
import Localize
import Stylize
import XPList

struct WebsiteList: View {
    
    @ObservedObject var dataSource: WebsiteDataSource
    @State var selection: WH.Selection = []
    
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var windowPresentation: WindowPresentation
    @EnvironmentObject private var errorQ: ErrorQueue
    
    var body: some View {
        XPL1.List(data: self.dataSource.data,
                  selection: self.$selection,
                  open: self.open,
                  menu: self.menu)
        { item in
            WebsiteRow(item: item)
        }
        .modifier(If.iOS(_Animation(.default)))
        .modifier(SyncIndicator(progress: self.dataSource.controller.syncProgress))
        .modifier(WebsiteListTitle(query: self.dataSource.query))
        // TODO: Fix the choppy EditMode animation caused by overly complex toolbars
        .modifier(DetailToolbar.Shared(controller: self.dataSource.controller,
                                       selection: self.$selection,
                                       query: self.$dataSource.query))
        .onAppear() { self.dataSource.activate(self.errorQ) }
        .onDisappear(perform: self.dataSource.deactivate)
    }
}

extension WebsiteList {
    private func open(_ items: WH.Selection) {
        if self.windowPresentation.features.contains([.bulkActivation, .multipleWindows]) {
            let validURLs = Set(items.compactMap({ $0.value.preferredURL }))
            self.windowPresentation.show(validURLs)
        } else {
            guard let validItem = items.first(where: { $0.value.preferredURL != nil }) else { return }
            self.modalPresentation.value = .browser(validItem)
        }
    }
    private func menu(_ items: WH.Selection) -> WebsiteMenu {
        WebsiteMenu(items, self.dataSource.controller)
    }
}

#if DEBUG
struct WebsiteList_Preview: PreviewProvider {
    static var previews: some View {
        WebsiteList(dataSource: WebsiteDataSource(controller: P_Controller()))
    }
}
#endif

internal struct _Animation: ViewModifier {
    let animation: Animation
    init(_ animation: Animation) {
        self.animation = animation
    }
    func body(content: Content) -> some View {
        content.animation(self.animation)
    }
}
