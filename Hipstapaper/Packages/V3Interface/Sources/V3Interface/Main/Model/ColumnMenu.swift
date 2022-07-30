//
//  Created by Jeffrey Bergier on 2022/07/30.
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

internal struct ColumnMenu: View {
    
    @Query private var query
    @V3Style.ColumnMenu private var style
    @V3Localize.ColumnMenu private var text
    
    internal var body: some View {
        Picker(selection: self.selectionMap) {
            self.style.dateModified
                .label(self.text.dateModified)
                .tag(true)
            self.style.dateCreated
                .label(self.text.dateCreated)
                .tag(false)
        } label: {
            // TODO: Figure out how to make this show in toolbar
            self.style.menu.label(self.text.menu)
        }
    }
    
    private var selectionMap: Binding<Bool> {
        self.$query.sort.map {
            switch $0 {
            case .dateModifiedNewest, .dateModifiedOldest:
                return true
            default:
                return false
            }
        } set: {
            switch $0 {
            case true:
                return .dateModifiedNewest
            case false:
                return .dateCreatedNewest
            }
        }
    }
}
