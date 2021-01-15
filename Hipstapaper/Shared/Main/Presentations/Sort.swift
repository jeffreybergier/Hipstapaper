//
//  Created by Jeffrey Bergier on 2021/01/01.
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
import Stylize
import Localize
import Datum

struct Sort: View {
    
    @Binding var selection: Datum.Sort!
    let doneAction: Action
    
    var body: some View {
        List(Datum.Sort.allCases, id: \.self, selection: self.$selection) { order in
            STZ.VIEW.TXT(order.localized)
                .font(.headline)
                .modifier(STZ.PDG.Default(ignore: [\.leading, \.trailing]))
        }
        .modifier(ModalSelectionStyle())
        .modifier(STZ.MDL.Done(kind: STZ.TB.Sort.self, done: self.doneAction))
        .frame(idealWidth: 300, idealHeight: 300)
    }
}

extension Datum.Sort {
    fileprivate var localized: LocalizedStringKey {
        switch self {
        case .dateModifiedNewest:
            return Phrase.SortDateModifiedNewest
        case .dateModifiedOldest:
            return Phrase.SortDateModifiedOldest
        case .dateCreatedNewest:
            return Phrase.SortDateCreatedNewest
        case .dateCreatedOldest:
            return Phrase.SortDateCreatedOldest
        case .titleA:
            return Phrase.SortTitleA
        case .titleZ:
            return Phrase.SortTitleZ
        }
    }
}
