//
//  Created by Jeffrey Bergier on 2020/12/20.
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
import Datum2
import Stylize
import Localize

struct TagNamePicker: View {
    
    let done: Action
    @Localize private var text
    @TagEditQuery private var tag: Tag
    
    init(id: Tag.Ident, done: @escaping Action) {
        self.done = done
        _tag = .init(id: id)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            STZ.VIEW.TXTFLD.TagName.textfield(self.$tag.name,
                                              bundle: self.text)
            Spacer()
        }
        .modifier(STZ.PDG.Equal())
        .modifier(STZ.MDL.Done(kind: STZ.TB.EditTag.self, done: self.done))
        .frame(idealWidth: 375, idealHeight: self.__hack_height) // TODO: Remove height when this is not broken
    }
    
    private var __hack_height: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 120
        #endif
    }
}
