//
//  Created by Jeffrey Bergier on 2022/07/03.
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
internal struct Navigation: DynamicProperty {
    internal static func newEnvironment() -> ObserveBox<Value> {
        ObserveBox(.init())
    }
    @EnvironmentObject internal var raw: ObserveBox<Value>
    internal init() {}
    internal var wrappedValue: Value {
        get { self.raw.value }
        nonmutating set { self.raw.value = newValue }
    }
    internal var projectedValue: Binding<Value> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}

extension Navigation {
    internal struct Value {
        internal var isLoading             = false
        internal var isJSEnabled           = false
        internal var shouldStop            = false
        internal var shouldReload          = true
        internal var shouldSnapshot        = false
        internal var shouldLoadURL: URL?
        
        internal var isError: CodableError?
        internal var isErrorList = Basic()
        internal var isPresenting: Bool { self.isError != nil }
        
        internal struct Basic: Codable {
            internal var isError: CodableError?
            internal var isPresented: Bool = false
            internal var isPresenting: Bool {
                self.isError != nil
            }
        }
    }
}
