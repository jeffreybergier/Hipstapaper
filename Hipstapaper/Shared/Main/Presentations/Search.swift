//
//  Created by Jeffrey Bergier on 2020/12/05.
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

struct Search: View {
    
    @Binding var searchString: String
    let doneAction: Action
    
    var body: some View {
        VStack {
            HStack {
                STZ.VIEW.TXTFLD.Search.textfield(self.$searchString)
                if self.searchString.trimmed != nil {
                    STZ.TB.ClearSearch.button_iconOnly(action: { self.searchString = "" })
                }
            }
            .animation(.default)
            Spacer()
        }
        .modifier(STZ.PDG.Equal())
        .modifier(STZ.MDL.Done(kind: STZ.TB.SearchActive.self, done: self.doneAction))
        .frame(idealWidth: 375, idealHeight: self.__hack_height) // TODO: Remove height when this is not broken
    }
    
    private var __hack_height: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 120
        #endif
    }
}
