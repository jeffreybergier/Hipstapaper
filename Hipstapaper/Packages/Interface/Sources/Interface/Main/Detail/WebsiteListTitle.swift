//
//  Created by Jeffrey Bergier on 2021/01/24.
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
import Localize

struct WebsiteListTitle: ViewModifier {
    let tag: Tag.Ident
    let isOnlyNotArchived: Bool
    @ViewBuilder func body(content: Content) -> some View {
        if self.tag.isSpecialTag {
            switch self.isOnlyNotArchived {
            case false:
                content.navigationTitle(Noun.allItems.rawValue)
                    .modifier(TitleSize(isLarge: false))
            case true:
                content.navigationTitle(Noun.hipstapaper.rawValue)
                    .modifier(TitleSize(isLarge: true))
            }
        } else {
            content
                .navigationTitle(Noun.untitled_L)
                .modifier(TitleSize(isLarge: false))
        }
    }
}

fileprivate struct TitleSize: ViewModifier {
    let isLarge: Bool
    @ViewBuilder func body(content: Content) -> some View {
        #if os(macOS)
        content
        #else
        content.navigationBarTitleDisplayMode(self.isLarge ? .large : .inline)
        #endif
    }
}
