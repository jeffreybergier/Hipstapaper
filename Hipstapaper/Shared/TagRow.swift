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

struct TagRow: View {
    
    var title: String?
    var websitesCount: Int? = nil
    
    var body: some View {
        HStack {
            RowTitle(self.title)
            if let count = self.websitesCount {
                Spacer()
                Text(String(count))
                    .font(.callout)
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8))
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray))
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

