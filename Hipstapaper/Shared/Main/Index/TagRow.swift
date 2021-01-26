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
import Stylize
import Localize

struct TagRow: View {
    let title: String?
    let websitesCount: Int?
    var body: some View {
        HStack {
            STZ.VIEW.TXT(self.title, or: Noun.Untitled)
                .modifier(STZ.CLR.IndexRow.Text.foreground())
                .modifier(STZ.FNT.IndexRow.Title.apply())
            if let count = self.websitesCount {
                Spacer()
                STZ.VIEW.NumberOval(count)
            }
        }
        .frame(height: 30)
    }
    init(_ tag: AnyTag) {
        self.title = tag.name
        self.websitesCount = tag.websitesCount
    }
    init(_ title: String) {
        self.title = title
        self.websitesCount = nil
    }
}

#if DEBUG
struct TagRow_Preview1: PreviewProvider {
    static var previews: some View {
        TagRow(p_tags[0].value)
    }
}
struct TagRow_Preview2: PreviewProvider {
    static var previews: some View {
        TagRow(p_tags[2].value)
    }
}
#endif

