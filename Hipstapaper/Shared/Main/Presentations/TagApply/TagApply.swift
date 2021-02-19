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
import Umbrella
import Datum
import Stylize
import Localize

struct TagApply: View {
    
    let controller: Controller
    let selection: WH.Selection
    let done: Action
    
    @EnvironmentObject private var errorQ: ErrorQueue
    
    var body: some View {
        let result = self.controller.tagStatus(for: self.selection)
        result.error.map {
            self.errorQ.queue.append($0)
            log.error($0)
        }
        return self.build(result)
    }
    
    @ViewBuilder private func build(_ result: Result<AnyList<(AnyElementObserver<AnyTag>, ToggleState)>, Datum.Error>) -> some View {
        switch result {
        case .success(let data):
            VStack(spacing: 0) {
                List(data, id: \.0) { tuple in
                    TagApplyRow(name: tuple.0.value.name,
                                value: tuple.1.boolValue,
                                valueChanged: { self.process(newValue: $0, for: tuple.0) })
                }
                .modifier(STZ.MDL.Done(kind: STZ.TB.TagApply.self, done: self.done))
                .frame(idealWidth: 300, idealHeight: 300)
            }
        case .failure:
            EmptyView()
        }
    }
    
    private func process(newValue: Bool, for tag: AnyElementObserver<AnyTag>) {
        let selection = self.selection
        let result = newValue
            ? self.controller.add(tag: tag, to: selection)
            : self.controller.remove(tag: tag, from: selection)
        result.error.map {
            self.errorQ.queue.append($0)
            log.error($0)
        }
    }
}
