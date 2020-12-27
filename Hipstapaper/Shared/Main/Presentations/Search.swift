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
    let doneAction: Modal.Action
    
    var body: some View {
        HStack {
            TextField.Search(self.$controller.detailQuery.search)
            if self.controller.detailQuery.search.nonEmptyString != nil {
                ButtonToolbar(systemName: "xmark.circle", accessibilityLabel: Verb.ClearSearch) {
                    self.controller.detailQuery.search = ""
                }
            }
        }
        .animation(.default)
        .paddingDefault_Equal()
        .modifier(Modal.Done(title: Noun.Search, done: self.doneAction))
        .frame(width: 250, height: 150) // TODO: Remove height when this is not broken
    }
}
