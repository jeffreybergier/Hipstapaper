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
    
    let selectedWebsites: Set<AnyElement<AnyWebsite>>
    let controller: Controller
    let done: Action
    
    var body: some View {
        // TODO: Figure out how to remove VStack without ruining layout on iOS
        VStack(spacing: 0) {
            List(try! self.controller.tagStatus(for: self.selectedWebsites).get(),
                id: \.0)
            { tuple in
                TagApplyRow(name: tuple.0.value.name, value: tuple.1.boolValue)
                { newValue in
                    switch newValue {
                    case true:
                        // TODO: Fix try!
                        try! self.controller.add(
                            tag: tuple.0,
                            to: self.selectedWebsites
                        ).get()
                    case false:
                        // TODO: Fix try!
                        try! self.controller.remove(
                            tag: tuple.0,
                            from: self.selectedWebsites
                        ).get()
                    }
                }
            }
            .modifier(STZ.MDL.Done(kind: STZ.TB.TagApply.self, done: self.done))
            .frame(idealWidth: 300, idealHeight: 300)
        }
    }
}
