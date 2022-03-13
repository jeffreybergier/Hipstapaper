//
//  Created by Jeffrey Bergier on 2021/01/01.
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
import Stylize
import Localize
import Datum2

struct SortPicker: View {
    
    let doneAction: Action
    @SceneSort private var sort
    
    var body: some View {
        List(Sort.allCases,
             id: \.self,
             selection: self.$sort)
        { order in
            order.label.label()
                .modifier(STZ.PDG.Default(ignore: [\.leading, \.trailing]))
        }
        .modifier(Force.PlainListStyle())
        .modifier(Force.EditMode())
        .modifier(STZ.MDL.Done(kind: STZ.TB.Sort.self, done: self.doneAction))
        .modifier(__Size())
    }
}

fileprivate struct __Size: ViewModifier {
    fileprivate func body(content: Content) -> some View {
        #if os(macOS)
        return content.frame(idealWidth: 300, idealHeight: 300)
        #else
        return content.frame(idealWidth: 400, idealHeight: 300)
        #endif
    }
}

extension Sort {
    fileprivate var label: Labelable.Type {
        switch self {
        case .dateModifiedNewest:
            return STZ.LBL.Sort.ModifiedNewest.self
        case .dateModifiedOldest:
            return STZ.LBL.Sort.ModifiedOldest.self
        case .dateCreatedNewest:
            return STZ.LBL.Sort.CreatedNewest.self
        case .dateCreatedOldest:
            return STZ.LBL.Sort.CreatedOldest.self
        case .titleA:
            return STZ.LBL.Sort.TitleA.self
        case .titleZ:
            return STZ.LBL.Sort.TitleZ.self
        }
    }
}
