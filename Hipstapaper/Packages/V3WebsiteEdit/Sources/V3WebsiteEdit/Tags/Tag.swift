//
//  Created by Jeffrey Bergier on 2022/06/25.
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
import V3Localize
import V3Style
import V3Model
import V3Store

internal struct Tag: View {
    
    @TagApplyQuery private var data
    @V3Localize.WebsiteEdit private var text
    
    private let selection: Website.Selection
    
    internal init(_ selection: Website.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        NavigationStack {
            Group {
                if self.data.isEmpty {
                    EmptyState()
                } else {
                    Form {
                        ForEach(self.$data) { item in
                            Toggle(item.wrappedValue.tag.name ?? self.text.untitled,
                                   isOn: item.status.boolValue.flipped)
                        }
                    }
                }
            }
            .modifier(TagToolbar.toolbar)
        }
        .frame(idealWidth: 320, minHeight: 320)
        .onLoadChange(of: self.selection) {
            _data.selection = $0
        }
    }
}