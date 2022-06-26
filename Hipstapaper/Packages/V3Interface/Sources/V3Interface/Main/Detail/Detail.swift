//
//  Created by Jeffrey Bergier on 2022/06/17.
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
import V3Model
import V3Store

internal struct Detail: View {
    
    @Nav private var nav
    @EditMode private var editMode
    @SizeClass private var sizeClass
    
    internal var body: some View {
        NavigationStack {
            Group {
                switch self.sizeClass.horizontal {
                case .regular:
                    DetailTable()
                case .compact:
                    DetailList()
                }
            }
            .modifier(.detailTitle)
            .modifier(.detailMenu)
            .modifier(DetailToolbar()) // TODO: change back to (.detailToolbar)
            .sheetCover(item: self.$nav.detail.isBrowse) { ident in
                Text("Browser: \(ident.rawValue)")
            }
            .onChange(of: self.nav.detail.selectedWebsites) { selection in
                guard selection.count == 1, self.editMode == false else { return }
                self.nav.detail.isBrowse = selection.first!
            }
        }
    }
}
