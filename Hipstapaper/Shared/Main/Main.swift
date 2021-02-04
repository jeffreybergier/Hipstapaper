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
    
    let controller: Controller
    private let tagDataSource: TagDataSource
    
    @StateObject private var websiteControllerCache: BlackBox<AnyElement<AnyTag>, WebsiteDataSource> = .init()

    init(controller: Controller) {
        self.controller = controller
        self.tagDataSource = .init(controller: self.controller)
    }
    
    var body: some View {
        NavigationView {
            TagList(dataSource: self.tagDataSource,
                    navigation: { selectedTag in
                        let ds = self.websiteControllerCache[selectedTag] {
                            return WebsiteDataSource(controller: self.controller,
                                                     selectedTag: selectedTag)
                        }
                        return AnyView(
                            WebsiteList(dataSource: ds)
                                .modifier(DetailToolbar.Shared(dataSource: ds))
                        )
                    })
                .modifier(IndexToolbar(dataSource: self.tagDataSource))
        }
        .modifier(BrowserPresentable())
        .modifier(STZ.ERR.PresenterB())
    }
}

#if DEBUG
struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main(controller: P_Controller())
    }
}
#endif
