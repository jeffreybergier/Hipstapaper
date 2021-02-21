//
//  Created by Jeffrey Bergier on 2021/01/24.
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

struct WebsiteListTitle: ViewModifier {
    let query: Query
    @ViewBuilder func body(content: Content) -> some View {
        if let tag = self.query.tag {
            content
                .navigationTitle(tag.value.name ?? Noun.unreadItems_L)
                .modifier(TitleSize(isLarge: false))
        } else {
            switch self.query.filter! {
            case .all:
                content.navigationTitle(Noun.allItems.rawValue)
                    .modifier(TitleSize(isLarge: false))
            case .unarchived:
                content.navigationTitle(Noun.hipstapaper.rawValue)
                    .modifier(TitleSize(isLarge: true))
            }
        }
    }
}

fileprivate struct TitleSize: ViewModifier {
    let isLarge: Bool
    @ViewBuilder func body(content: Content) -> some View {
        #if os(macOS)
        content
        #else
        content.navigationBarTitleDisplayMode(self.isLarge ? .large : .inline)
        #endif
    }
}
