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
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

struct SectionTitle: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.title3)
            .frame(height: 30)
    }
    
    init(_ title: String) {
        self.title = title
    }
}

struct RowTitle: View {
    var title: String?
    var body: Text {
        if let title = self.title {
            return Text(title)
                .font(.headline)
        } else {
            return Text("Untitled")
                .font(.headline)
        }
    }
    init(_ title: String?) {
        self.title = title
    }
}

struct DateSubtitle: View {
    
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }()
    
    var date: Date
    
    var body: Text {
        return Text(DateSubtitle.formatter.string(from: self.date))
            .font(.subheadline)
    }
    
    init(_ date: Date) {
        self.date = date
    }
}
