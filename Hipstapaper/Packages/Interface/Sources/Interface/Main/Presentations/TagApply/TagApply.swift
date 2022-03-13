//
//  Created by Jeffrey Bergier on 2020/12/14.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI
import Umbrella
import Datum2
import Stylize
import Localize

struct TagApply: View {
    
    let controller: Controller
    let selection: WH.Selection
    let done: Action
    
    @EnvironmentObject private var errorEnvironment: ErrorQueueEnvironment
    
    var body: some View {
        Text("// TODO: Fix DATUM")
    }
    
    // TODO: Fix DATUM
    /*
    var body: some View {
        let result = self.controller.tagStatus(for: self.selection)
        result.error.map {
            self.errorQ.queue.append($0)
            log.error($0)
        }
        return self.build(result)
    }
    
    @ViewBuilder private func build(_ result: Result<AnyRandomAccessCollection<(AnyElementObserver<AnyTag>, ToggleState)>, Datum.Error>) -> some View {
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
    */
}
