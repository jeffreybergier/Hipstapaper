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
import Umbrella
import Stylize
import Localize
import Datum

struct Sort: View {
    
    @Binding var selection: Datum.Sort!
    let doneAction: Action
    
    var body: some View {
        List(Datum.Sort.allCases, id: \.self, selection: self.$selection)
        { order in
            order.label.label()
                .modifier(STZ.PDG.Default(ignore: [\.leading, \.trailing]))
        }
        .modifier(Force.PlainListStyle())
        .modifier(Force.EditMode())
        .modifier(STZ.MDL.Done(kind: STZ.TB.Sort.self, done: self.doneAction))
        .modifier(__Size())
    }
}

fileprivate struct __Size: ViewModifier {
    fileprivate func body(content: Content) -> some View {
        #if os(macOS)
        return content.frame(idealWidth: 300, idealHeight: 300)
        #else
        return content.frame(idealWidth: 400, idealHeight: 300)
        #endif
    }
}

extension Datum.Sort {
    fileprivate var label: Labelable.Type {
        switch self {
        case .dateModifiedNewest:
            return STZ.LBL.Sort.ModifiedNewest.self
        case .dateModifiedOldest:
            return STZ.LBL.Sort.ModifiedOldest.self
        case .dateCreatedNewest:
            return STZ.LBL.Sort.CreatedNewest.self
        case .dateCreatedOldest:
            return STZ.LBL.Sort.CreatedOldest.self
        case .titleA:
            return STZ.LBL.Sort.TitleA.self
        case .titleZ:
            return STZ.LBL.Sort.TitleZ.self
        }
    }
}
