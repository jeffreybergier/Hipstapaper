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

struct WebsiteList: View {
    
    @ObservedObject private var controller: WebsiteController
    @StateObject private var clickController = ClickActions.Controller()
    
    init(controller: Controller, selectedTag: AnyElement<AnyTag>) {
        let websiteController = WebsiteController(controller: controller, selectedTag: selectedTag)
        _controller = ObservedObject(initialValue: websiteController)
    }
    
    init(controller: WebsiteController) {
        _controller = ObservedObject(initialValue: controller)
    }
    
    var body: some View {
        return List(self.controller.all,
                    id: \.self,
                    selection: self.$controller.selectedWebsites)
        { item in
            WebsiteRow(item.value).modifier(
                ClickActions.SingleClick(item: item, controller: self.clickController)
            )
        }
        .modifier(Title(query: self.controller.query))
        .modifier(ClickActions.Modifier(controller: self.clickController))
    }
}

#if DEBUG
struct WebsiteList_Preview: PreviewProvider {
    static var previews: some View {
        WebsiteList(controller: WebsiteController(controller: P_Controller()))
    }
}
#endif

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
