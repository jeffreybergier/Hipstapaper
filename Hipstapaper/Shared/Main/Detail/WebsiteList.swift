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
    
    @ObservedObject var controller: WebsiteController
    
    init(controller: Controller, selectedTag: AnyElement<AnyTag>) {
        let websiteController = WebsiteController(controller: controller, selectedTag: selectedTag)
        _controller = ObservedObject(initialValue: websiteController)
    }
    
    init(controller: WebsiteController) {
        _controller = ObservedObject(initialValue: controller)
    }
    
    var body: some View {
        // TODO: Delete workaround for crashing mac app
        let content = self.controller.all.count > 0
            ? AnyView(
                List(self.controller.all,
                     id: \.self,
                     selection: self.$controller.selectedWebsites)
                { item in
                    WebsiteRow(item.value)
                }
            )
            : AnyView(Color.windowBackground)
        return content
            .navigationTitle(Noun.Hipstapaper)
            .modifier(ListEditMode())
    }
}

#if DEBUG
struct WebsiteList_Preview: PreviewProvider {
    static var previews: some View {
        WebsiteList(controller: WebsiteController(controller: P_Controller()))
    }
}
#endif
