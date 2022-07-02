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
import V3Model
import V3Style
import V3Localize

internal struct SortMenu: View {
    
    @Query private var query
    @V3Style.SortMenu private var style
    @V3Localize.SortMenu private var text
    
    internal var body: some View {
        self.style.menu.menu(self.text.menu) {
            ForEach(Sort.allCases) { sort in
                switch sort {
                case .dateModifiedOldest:
                    Button(action: self.closure(sort)) {
                        self.style.sortDateModifiedOldest.label(self.text.sortDateModifiedOldest)
                    }
                case .dateModifiedNewest:
                    Button(action: self.closure(sort)) {
                        self.style.sortDateModifiedNewest.label(self.text.sortDateModifiedNewest)
                    }
                case .dateCreatedOldest:
                    Button(action: self.closure(sort)) {
                        self.style.sortDateCreatedOldest.label(self.text.sortDateCreatedOldest)
                    }
                case .dateCreatedNewest:
                    Button(action: self.closure(sort)) {
                        self.style.sortDateCreatedNewest.label(self.text.sortDateCreatedNewest)
                    }
                case .titleZ:
                    Button(action: self.closure(sort)) {
                        self.style.sortTitleZ.label(self.text.sortTitleZ)
                    }
                case .titleA:
                    Button(action: self.closure(sort)) {
                        self.style.sortTitleA.label(self.text.sortTitleA)
                    }
                }
            }
        }
    }
    
    private func closure(_ sort: Sort) -> () -> Void {
        { self.query.sort = [sort] }
    }
}