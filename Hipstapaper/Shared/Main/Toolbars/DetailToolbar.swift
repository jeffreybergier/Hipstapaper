//
//  Created by Jeffrey Bergier on 2020/12/03.
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
import Browse

enum DetailToolbar {
    struct Shared: ViewModifier {
        
        let controller: Controller
        @Binding var selection: WH.Selection
        @Binding var query: Query
        
        @State private var popoverAlignment: Alignment = .topTrailing

        func body(content: Content) -> some View {
            return ZStack(alignment: self.popoverAlignment) {
                // TODO: Hack when toolbars work properly with popovers
                Color.clear.frame(width: 1, height: 1).modifier(
                    TagApplyPresentable(controller: self.controller)
                )
                Color.clear.frame(width: 1, height: 1).modifier(
                    SharePresentable()
                )
                Color.clear.frame(width: 1, height: 1).modifier(
                    SearchPresentable(search: self.$query.search)
                )
                Color.clear.frame(width: 1, height: 1).modifier(
                    SortPresentable(sort: self.$query.sort)
                )
                Color.clear.frame(width: 1, height: 1).modifier(
                    WebsiteDelete(controller: self.controller)
                )
                    
                #if os(macOS)
                content.modifier(macOS(controller: self.controller, selection: self.$selection, query: self.$query))
                #else
                content.modifier(iOS.Shared(controller: self.controller,
                                            selection: self.$selection,
                                            query: self.$query,
                                            popoverAlignment: self.$popoverAlignment))
                #endif
            }
        }
    }
}
