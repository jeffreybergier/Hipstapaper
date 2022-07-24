//
//  Created by Jeffrey Bergier on 2022/07/19.
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

internal struct SyncIndicatorOval: ViewModifier {
    
    @Environment(\.colorScheme) private var scheme
    @Environment(\.tintColor) private var tintColor
    
    private var color: Color {
        self.scheme == .light ? self.tintColor : .grayDark(self.scheme)
    }
    
    private var brightness: CGFloat {
        self.scheme == .light ? 0.15 : 0
    }
    
    internal func body(content: Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1000)
                .fill(self.color)
                .frame(minWidth: .ovalWidthMinimum)
                .brightness(self.brightness)
                .shadow(radius: 0.8)
                .layoutPriority(0.9)
            content
                .padding([.leading, .trailing], .paddingOvalHorizontal)
                .padding([.top, .bottom], .paddingOvalVertical)
                .layoutPriority(1.0)
        }
        .monospacedDigit()
    }
}
