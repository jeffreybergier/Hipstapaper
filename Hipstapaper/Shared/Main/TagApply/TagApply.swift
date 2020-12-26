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
    @State var presentation: Presentation.Wrap
    
    var body: some View {
        VStack(spacing: 0) {
            Toolbar {
                HStack {
                    Spacer()
                    Text.ModalTitle(Verb.ApplyTags)
                    Spacer()
                    ButtonDone(Verb.Done) { self.presentation.isTagApply = false }
                }
            }
            List(self.controller.controller.tagStatus(for: self.controller.selectedWebsites).value!, id: \.0) { tuple in
                TagApplyRow(name: tuple.0.value.name, value: tuple.1.boolValue) { newValue in
                    switch newValue {
                    case true:
                        // TODO: Fix try!
                        try! self.controller.controller.add(tag: tuple.0, to: self.controller.selectedWebsites).get()
                    case false:
                        // TODO: Fix try!
                        try! self.controller.controller.remove(tag: tuple.0, from: self.controller.selectedWebsites).get()
                    }
                }
            }
            .frame(width: 300, height: 300)
        }
    }
}
