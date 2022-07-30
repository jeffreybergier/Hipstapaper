//
//  Created by Jeffrey Bergier on 2022/06/19.
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
import V3Localize
import V3Style

internal struct SidebarUserRow: View {
        
    @TagUserQuery private var item: Tag?
    @V3Style.Sidebar private var style
    @V3Localize.Sidebar private var text
    
    private let identifier: Tag.Identifier
    
    internal init(_ id: Tag.Identifier) {
        self.identifier = id
    }
    
    internal var body: some View {
        Group {
            HStack {
                JSBText(self.text.rowTitleUntitled, text: self.item?.name)
                    .modifier(self.style.titleText)
                if self.style.accessibilityMode == false,
                   let count = self.item?.websitesCount
                {
                    Spacer()
                    Text(String(describing: count))
                        .modifier(self.style.itemCountOval)
                }
            }
        }
        .onLoadChange(of: self.identifier) {
            _item.setIdentifier($0)
        }
    }
}
