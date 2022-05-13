//
//  Created by Jeffrey Bergier on 2022/05/11.
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
import Datum
import Stylize
import Localize

internal struct MultiWebsiteEdit: View {
    
    @ErrorQueue private var errorQ
    
    private let selection: [Website.Ident]
    private let mode: Mode
    private let onDone: Action
    
    public init(_ mode: Mode, _ selection: Set<Website.Ident>, onDone: @escaping Action) {
        self.selection = Array(selection)
        self.mode = mode
        self.onDone = onDone
    }
    
    internal var body: some View {
        List(self.selection) { id in
            ManualForm(id)
                .modifier(Force.ListRowSeparatorHidden())
                .modifier(STZ.PDG.Equal(ignore: [\.top, \.leading, \.trailing]))
        }
        .listStyle(.plain)
        .if(.macOS) { $0.frame(width: 500, height: 300) }
        .modifier(STZ.MDL.Done(
            kind: self.mode == .add ? STZ.TB.AddWebsite.self : STZ.TB.EditWebsite.self,
            done: self.onDone)
        )
        .modifier(ErrorPresentation(self.$errorQ))
    }
}
