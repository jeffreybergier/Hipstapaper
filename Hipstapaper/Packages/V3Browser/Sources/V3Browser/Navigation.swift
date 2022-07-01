//
//  Created by Jeffrey Bergier on 2022/07/01.
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

internal struct Navigation {
    internal var canGoBack       = false
    internal var canGoForward    = false
    internal var shouldGoBack    = false
    internal var shouldGoForward = false
    internal var shouldStop      = false
    internal var shouldReload    = false
    internal var isLoading       = false
    internal var isJSEnabled     = false
    internal var currentTitle    = "Loading..."
    internal var currentPath: URL?
}

@propertyWrapper
internal struct Nav: DynamicProperty {
    
    internal static func newEnvironment() -> BlackBox<Navigation> {
        BlackBox(Navigation(), isObservingValue: true)
    }

    @EnvironmentObject internal var raw: BlackBox<Navigation>
    
    internal init() {}
    
    internal var wrappedValue: Navigation {
        get { self.raw.value }
        nonmutating set { self.raw.value = newValue }
    }
    
    internal var projectedValue: Binding<Navigation> {
        .init {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}
