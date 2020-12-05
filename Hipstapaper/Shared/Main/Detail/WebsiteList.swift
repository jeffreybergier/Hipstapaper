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

struct WebsiteList: View {
    
    @ObservedObject var controller: AnyUIController
    
    var body: some View {
        return List(self.controller.detailWebsites.value!,
                    id: \.value,
                    selection: self.$controller.selectedWebsite)
        { item in
            WebsiteRow(item.value)
        }
        .navigationTitle("Hipstapaper")
    }
}

#if DEBUG
struct WebsiteList_Preview: PreviewProvider {
    static var previews: some View {
        WebsiteList(controller: P_UIController.new())
    }
}
#endif
