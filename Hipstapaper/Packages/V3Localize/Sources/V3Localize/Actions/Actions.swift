//
//  Created by Jeffrey Bergier on 2022/08/12.
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

import Umbrella

extension ActionLocalization {
    internal static func openInApp(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.openInApp.rawValue),
              hint:  b.localized(key: Phrase.openInApp.rawValue),
              image: .init(Symbol.openInApp, bundle: b),
              shortcut: .commandO)
    }
    internal static func openExternal(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.openExternal.rawValue),
              hint:  b.localized(key: Phrase.openExternal.rawValue),
              image: .init(Symbol.openExternal, bundle: b),
              shortcut: .commandShiftO)
    }
}

import Umbrella

extension ActionLabelImage {
    internal init(_ string: Symbol, bundle: LocalizeBundle) {
        // TODO: Use bundle if needed
        self = .system(string.rawValue)
    }
}
