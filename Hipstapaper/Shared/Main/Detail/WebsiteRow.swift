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
import Snapshot

struct WebsiteRow: View {
    
    var website: AnyWebsite
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                RowTitle(self.website.title)
                DateSubtitle(self.website.dateCreated)
            }
            Spacer()
            Thumbnail(self.website.thumbnail)
                .scaledToFit()
        }
        .frame(height: 60)
    }
    
    init(_ website: AnyWebsite) {
        self.website = website
    }
}

#if DEBUG
struct WebsiteRow_Preview1: PreviewProvider {
    static var previews: some View {
        WebsiteRow(p_sites[0].value)
    }
}
struct WebsiteRow_Preview2: PreviewProvider {
    static var previews: some View {
        WebsiteRow(p_sites[2].value)
    }
}
#endif
