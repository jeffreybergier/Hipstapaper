//
//  Created by Jeffrey Bergier on 2022/08/02.
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

@propertyWrapper
public struct ShareList: DynamicProperty {

    public struct Value {
        public func enabled(subtitle: String) -> some ActionStyle {
            ActionStyleImp(modifier: ModifierSubtitle(subtitle: subtitle))
        }
        public func disabled(subtitle: String) -> some ActionStyle {
            ActionStyleImp(modifier: ModifierCombo(m1: ModifierSubtitle(subtitle: subtitle),
                                                   m2: ModifierDisabledFake()))
        }
        public var copy: some ActionStyle = ActionStyleImp(
            label: .iconOnly,
            modifier: ModifierButtonStyle(style: .bordered)
        )
        public var popoverSize: some ViewModifier = PopoverSize(size: .medium)
    }
    
    public init() {}
    
    public var wrappedValue: Value {
        Value()
    }
}

fileprivate struct ModifierCombo<M1: ViewModifier, M2: ViewModifier>: ViewModifier {
    private let m1: M1
    private let m2: M2
    fileprivate init(m1: M1, m2: M2) {
        self.m1 = m1
        self.m2 = m2
    }
    fileprivate func body(content: Content) -> some View {
        content
            .modifier(m1)
            .modifier(m2)
    }
}

fileprivate struct ModifierSubtitle: ViewModifier {
    private let subtitle: String
    fileprivate init(subtitle: String) {
        self.subtitle = subtitle
    }
    fileprivate func body(content: Content) -> some View {
        VStack(alignment: .listRowSeparatorLeading, spacing: .labelVSpacingSmall) {
            content
            Text(self.subtitle)
                .font(.small)
        }
        // TODO: Figure out why this is causing a layout issue
        .lineLimit(1)
        .truncationMode(.middle)
    }
}
