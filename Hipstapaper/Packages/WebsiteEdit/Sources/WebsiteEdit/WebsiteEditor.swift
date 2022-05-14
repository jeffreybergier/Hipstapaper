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

public enum Mode {
    case add, edit
}

public struct WebsiteEditor: View {
    
    @ErrorQueue private var errorQ
    
    private let selection: Set<Website.Ident>
    private let mode: Mode
    private let onDone: Action
    
    public init(_ mode: Mode, _ selection: Set<Website.Ident>, onDone: @escaping Action) {
        self.selection = selection
        self.mode = mode
        self.onDone = onDone
    }
    
    public var body: some View {
        self.build
            .modifier(ErrorPresentation(self.$errorQ))
    }

    @ViewBuilder private var build: some View {
        switch self.selection.count {
        case 0: fatalError("// TODO: Show Error")
        case 1: SingleWebsiteEdit(self.mode, self.selection.first!, onDone: self.onDone)
        default: MultiWebsiteEdit(self.mode, self.selection, onDone: self.onDone)
        }
    }
}