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
import Collections
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
        .init {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    // TODO: Hack becase updating the value directly in update function throws runtime warnings
    internal func HACK_set<T>(_ keypath: WritableKeyPath<Navigation.Value, T>, _ newValue: T) {
        DispatchQueue.main.async {
            self.raw.value[keyPath: keypath] = newValue
        }
    }
}

extension Navigation {
    internal struct Value {
        internal var isLoading             = false
        internal var canGoBack             = false
        internal var canGoForward          = false
        internal var isJSEnabled           = false
        internal var shouldGoBack          = false
        internal var shouldGoForward       = false
        internal var shouldStop            = false
        internal var shouldReload          = true
        internal var shouldLoadURL: URL?
        internal var currentURL: URL?
        internal var currentTitle          = ""
        
        internal var isError: ErrorStorage.Identifier?
        internal var isErrorList = Basic()
        internal var isShareList: ShareList.Data?
        internal var isPresenting: Bool {
            return self.isError != nil
            || self.isErrorList.isPresented
            || self.isShareList != nil
        }
        
        internal struct Basic: Codable {
            internal var isPresented: Bool = false
        }
    }
}
