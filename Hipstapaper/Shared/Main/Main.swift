//
//  Created by Jeffrey Bergier on 2020/11/23.
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
import Stylize

struct Main: View {
    
    var controller: Controller
    @State var selectedWebsites: Set<AnyElement<AnyWebsite>> = []
    @State var presentations = Presentation.Wrap()
    
    var body: some View {
        NavigationView {
            try! TagList(
                controller: self.controller,
                navigation: { selectedTag in
                    let c = WebsiteController(controller: self.controller, selectedTag: selectedTag)
                    return AnyView(WebsiteList(controller: c,
                                               selectedWebsites: self.$selectedWebsites,
                                               presentations: self.$presentations))
                }
            )
            .modifier(IndexToolbar(controller: self.controller,
                                   presentations: self.$presentations))
        }
    }
}

//#if DEBUG
//struct Main_Previews: PreviewProvider {
//    static var previews: some View {
//        Main(controller: P_UIController.new())
//    }
//}
//#endif
