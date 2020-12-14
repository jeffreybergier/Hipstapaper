//
//  Created by Jeffrey Bergier on 2020/12/14.
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

struct TagApply: View {
    
    @ObservedObject var controller: AnyUIController
    @Binding var presentation: Presentation.Wrap
    @State var on = true
    
    var body: some View {
        VStack(spacing: 0) {
            Toolbar {
                HStack {
                    Spacer()
                    Text.ModalTitle(ApplyTags)
                    Spacer()
                    ButtonDone(Done) { self.presentation.value = .none }
                }
            }
            List(self.controller.indexTags.value!) { tag in
                TagApplyRow(name: tag.value.name, isOn: self.$on)
            }
            .frame(width: 300, height: 300)
        }
    }
}
