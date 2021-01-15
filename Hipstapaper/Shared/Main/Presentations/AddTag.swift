//
//  Created by Jeffrey Bergier on 2020/12/20.
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
import Stylize
import Localize

struct AddTag: View {
    
    @State private var tagName: String = ""
    let cancel: Action
    let save: (String?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            STZ.VIEW.TXTFLD.TagName.textfield(self.$tagName)
            Spacer()
        }
        .modifier(STZ.PDG.Equal())
        .modifier(STZ.MDL.Save(kind: STZ.TB.AddTag.self,
                               cancel: self.cancel,
                               save: { self.save(self.tagName.nonEmptyString) },
                               canSave: { self.tagName.nonEmptyString != nil }))
        // TODO: Remove height when this is not broken
        .frame(idealWidth: 250, idealHeight: 150)
    }
}
