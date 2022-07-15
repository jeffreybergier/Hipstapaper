//
//  Created by Jeffrey Bergier on 2022/07/08.
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
import V3Localize
import V3Style

internal struct EmptyMod: ViewModifier {
    private let isEmpty: Bool
    internal init(_ isEmpty: Bool) {
        self.isEmpty = isEmpty
    }
    @ViewBuilder internal func body(content: Content) -> some View {
        if self.isEmpty {
            EmptyState()
        } else {
            content
        }
    }
}

internal struct EmptyView<T, V: View>: View {
    private let content: (T) -> V
    private let value: T?
    internal init(value: T?, @ViewBuilder content: @escaping (T) -> V) {
        self.content = content
        self.value = value
    }
    internal var body: some View {
        if let value {
            self.content(value)
        } else {
            EmptyState()
        }
    }
}

internal struct EmptyState: View {
    
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    
    internal var body: some View {
        // TODO: Localize
        self.style.empty.label(self.text.empty)
    }
}
