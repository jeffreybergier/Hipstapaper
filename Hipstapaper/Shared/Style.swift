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
import Localize

struct IndexRowTitle: View {
    var title: String?
    var body: some View {
        if let title = self.title {
            return AnyView(Text.IndexRowTitle(title))
        } else {
            return AnyView(Text.IndexRowTitleDisabled(Noun.Untitled))
        }
    }
    init(_ title: String?) {
        self.title = title
    }
}

struct DetailRowTitle: View {
    var title: String?
    var body: some View {
        if let title = self.title {
            return AnyView(Text.DetailRowTitle(title))
        } else {
            return AnyView(Text.DetailRowTitleDisabled(Noun.Untitled))
        }
    }
    init(_ title: String?) {
        self.title = title
    }
}

struct DetailRowDateSubtitle: View {
    
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }()
    
    var date: Date
    
    var body: Text.DetailRowSubtitle {
        Text.DetailRowSubtitle(DetailRowDateSubtitle.formatter.string(from: self.date))
    }
    
    init(_ date: Date) {
        self.date = date
    }
}
