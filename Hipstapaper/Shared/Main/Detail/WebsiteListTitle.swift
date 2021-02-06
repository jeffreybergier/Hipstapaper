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

#if os(macOS)
struct WebsiteListTitle: ViewModifier {
    let query: Query
    func body(content: Content) -> some View {
        if let tag = self.query.tag {
            return AnyView(content.navigationTitle(tag.value.name ?? Noun.UnreadItems_L))
        } else {
            switch self.query.filter! {
            case .all:
                return AnyView(content.navigationTitle(Noun.AllItems))
            case .unarchived:
                return AnyView(content.navigationTitle(Noun.Hipstapaper))
            }
        }
    }
}
#else
struct WebsiteListTitle: ViewModifier {
    let query: Query
    func body(content: Content) -> some View {
        if let tag = self.query.tag {
            return AnyView(
                content
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(tag.value.name ?? Noun.UnreadItems_L)
            )
        } else {
            switch query.filter! {
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
