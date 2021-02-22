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
import Stylize
import Localize

struct TagRow: View {
    @ObservedObject var item: AnyElementObserver<AnyTag>
    var body: some View {
        HStack {
            STZ.VIEW.TXT(self.item.value.name, or: Noun.untitled.rawValue)
                .modifier(STZ.CLR.IndexRow.Text.foreground())
                .modifier(STZ.FNT.IndexRow.Title.apply())
            if let count = self.item.value.websitesCount {
                Spacer()
                STZ.VIEW.NumberOval(count)
            }
        }
        .frame(height: 30)
    }
}

#if DEBUG
struct TagRow_Preview1: PreviewProvider {
    static var previews: some View {
        TagRow(item: p_tags[0])
    }
}
struct TagRow_Preview2: PreviewProvider {
    static var previews: some View {
        TagRow(item: p_tags[2])
    }
}
#endif

