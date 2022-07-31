//
//  Created by Jeffrey Bergier on 2022/07/31.
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

internal struct DetailToolbarCount: View {
    
    @Nav private var nav
    @BulkActions private var state
    
    private let totalItemCount: Int
    private var selectedItemCount: Int {
        self.nav.detail.selectedWebsites.count
    }
    
    internal init(_ itemCount: Int) {
        self.totalItemCount = itemCount
    }
    
    internal var body: some View {
        Menu {
            Button {
                self.state.push.deselectAll = true
            } label: {
                Label("Deselect All", systemImage: "tablecells")
            }
            .disabled(self.selectedItemCount == 0)
            Button {
                self.state.push.selectAll = true
            } label: {
                Label("Select All", systemImage: "tablecells.fill")
            }
            .disabled(self.totalItemCount == self.selectedItemCount)
        } label: {
            if self.selectedItemCount == 0 {
                Text("\(self.totalItemCount)項目")
            } else {
                Text("\(self.totalItemCount)項目中の\(self.selectedItemCount)項目を選択")
            }
        }
    }
}
