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
    
    @ErrorQueue private var errorQ
    @TagApplyQuery private var data: AnyRandomAccessCollection<Datum2.TagApply>
    
    let done: Action
    
    init(selection: WH.Selection, done: @escaping Action) {
        _data = .init(selection: Set(selection.map { $0.uuid }))
        self.done = done
    }

    var body: some View {
        VStack(spacing: 0) {
            List(self.data) { apply in
                TagApplyRow(name: apply.tag.name,
                            value: apply.status.boolValue,
                            valueChanged: { _ in /* self.process(newValue: $0, for: tuple.0) */ })
            }
            .modifier(STZ.MDL.Done(kind: STZ.TB.TagApply.self, done: self.done))
            .frame(idealWidth: 300, idealHeight: 300)
        }
    }
    
    /*
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
