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
import Datum
import Localize
import Stylize
import XPList

struct WebsiteList: View {
    
    @ObservedObject private var controller: WebsiteController
    @EnvironmentObject private var windowPresentation: WindowPresentation
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    
    init(controller: Controller, selectedTag: AnyElement<AnyTag>) {
        let websiteController = WebsiteController(controller: controller, selectedTag: selectedTag)
        _controller = ObservedObject(initialValue: websiteController)
    }
    
    init(controller: WebsiteController) {
        _controller = ObservedObject(initialValue: controller)
    }
    
    var body: some View {
        XPL.List(self.controller.all,
                 selection: self.$controller.selectedWebsites,
                 openAction: { items in
                    if self.windowPresentation.features.contains([.bulkActivation, .multipleWindows]) {
                        let validURLs = Set(items.compactMap({ $0.value.preferredURL }))
                        self.windowPresentation.show(validURLs, error: { _ in })
                    } else {
                        guard let validItem = items.first(where: { $0.value.preferredURL != nil }) else { return }
                        self.modalPresentation.value = .browser(validItem)
                    }
                 },
                 menu: { _ in })
        { item in
            WebsiteRow(item.value)
        }
        .modifier(Title(query: self.controller.query))
        .animation(.linear(duration: 0.1))
        .onAppear() { self.controller.activate() }
        .onDisappear() { self.controller.deactivate() }
    }
}

#if DEBUG
struct WebsiteList_Preview: PreviewProvider {
    static var previews: some View {
        WebsiteList(controller: WebsiteController(controller: P_Controller()))
    }
}
#endif

#if os(macOS)
fileprivate struct Title: ViewModifier {
    let query: Query
    func body(content: Content) -> some View {
        if let tag = self.query.tag {
            return AnyView(content.navigationTitle(tag.value.name ?? Noun.UnreadItems_L))
        } else {
            switch query.isArchived! {
            case .all:
                return AnyView(content.navigationTitle(Noun.AllItems))
            case .unarchived:
                return AnyView(content.navigationTitle(Noun.Hipstapaper))
            }
        }
    }
}
#else
fileprivate struct Title: ViewModifier {
    let query: Query
    func body(content: Content) -> some View {
        if let tag = self.query.tag {
            return AnyView(
                content
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(tag.value.name ?? Noun.UnreadItems_L)
            )
        } else {
            switch query.isArchived! {
            case .all:
                return AnyView(
                    content
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(Noun.AllItems)
                )
            case .unarchived:
                return AnyView(
                    content
                        .navigationBarTitleDisplayMode(.large)
                        .navigationTitle(Noun.Hipstapaper)
                )
            }
        }
    }
}
#endif
