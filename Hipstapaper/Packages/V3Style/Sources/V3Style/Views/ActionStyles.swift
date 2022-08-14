//
//  Created by Jeffrey Bergier on 2022/08/13.
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

internal let ActionStyleDefault:      some ActionStyle = ActionStyleImp()
/// Fake appearance style for use on Labels where there is no "real" disabled state
internal let ActionStyleFakeDisabled: some ActionStyle = ActionStyleImp(modifier: ModifierDisabledFake())
internal let ActionStyleDestructive:  some ActionStyle = ActionStyleImp(button: .destructive)

// TODO: Make these internal
// for some reason there is a build error
// when building for release when they are internal

public struct ModifierButtonStyle<S: PrimitiveButtonStyle>: ViewModifier {
    private let style: S
    public init(style: S) {
        self.style = style
    }
    public func body(content: Content) -> some View {
        content
            .buttonStyle(self.style)
    }
}

public struct ModifierDisabledFake: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    public func body(content: Content) -> some View {
        content
            .tint(Color.grayDark(self.scheme))
            .foregroundColor(Color.grayDark(self.scheme))
    }
}
