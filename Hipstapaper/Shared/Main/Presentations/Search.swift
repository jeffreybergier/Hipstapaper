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
    
    @ObservedObject var controller: AnyUIController
    @Binding var presentation: Presentation.Wrap
    
    var body: some View {
        VStack(spacing: 0) {
            Toolbar {
                HStack {
                    Spacer()
                    Text.ModalTitle(Localize.Search)
                    Spacer()
                    ButtonDone(Done) { self.presentation.value = .none }
                    .keyboardShortcut(.defaultAction)
                }
            }
            HStack {
                TextField.Search(self.$controller.detailQuery.search)
                if self.controller.detailQuery.search.nonEmptyString != nil {
                    ButtonToolbar(systemName: "xmark.circle", accessibilityLabel: ClearSearch) {
                        self.controller.detailQuery.search = ""
                    }
                }
            }
            .frame(width: 250)
            .paddingDefault_Equal()
        }
        .animation(.default)
    }
}
