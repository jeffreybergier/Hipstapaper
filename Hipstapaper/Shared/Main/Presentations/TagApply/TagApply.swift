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
    
    @EnvironmentObject private var errorQ: STZ.ERR.ViewModel
    
    var body: some View {
        guard let data = self.errorQ.append(self.controller.tagStatus(for: self.selectedWebsites))
            else { return AnyView(Color.clear) }
        // TODO: Figure out how to remove VStack without ruining layout on iOS
        return AnyView(
            VStack(spacing: 0) {
                List(data, id: \.0) { tuple in
                    TagApplyRow(name: tuple.0.value.name,
                                value: tuple.1.boolValue,
                                valueChanged: { self.process(newValue: $0, for: tuple.0) })
                }
                .modifier(STZ.MDL.Done(kind: STZ.TB.TagApply.self, done: self.done))
                .frame(idealWidth: 300, idealHeight: 300)
            }
        )
    }
    
    private func process(newValue: Bool, for tag: AnyElement<AnyTag>) {
        switch newValue {
        case true:
            self.errorQ.append(
                self.controller.add(tag: tag, to: self.selectedWebsites)
            )
        case false:
            self.errorQ.append(
                self.controller.remove(tag: tag, from: self.selectedWebsites)
            )
        }
    }
}
