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

struct WebsiteRow: View {
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }()
    let website: AnyWebsite
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                STZ.VIEW.TXT(self.website.title, or: Noun.Untitled)
                    .modifier(STZ.FNT.DetailRow.Title.apply())
                    .modifier(STZ.CLR.DetailRow.Text.foreground())
                STZ.VIEW.TXT(WebsiteRow.formatter.string(from: self.website.dateCreated))
                    .modifier(STZ.FNT.DetailRow.Subtitle.apply())
                    .modifier(STZ.CLR.DetailRow.Text.foreground())
            }
            Spacer()
            STZ.IMG.Placeholder.thumbnail(self.website.thumbnail)
        }
        .frame(height: 60)
        .animation(nil)
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
