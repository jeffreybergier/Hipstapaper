//
//  Created by Jeffrey Bergier on 2022/06/17.
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
import V3Model

@propertyWrapper
public struct WebsiteQuery: DynamicProperty {
    
    // TODO: Hook up core data
    @ObservedObject private var data = siteEnvironment
    
    @State public var identifier: Website.Identifier?
    
    public init() { }
    
    public var wrappedValue: Website? {
        get { index.map { data.value[$0] }}
        nonmutating set {
            guard let index else { return }
            if let newValue {
                data.value[index] = newValue
            } else {
                data.value.remove(at: index)
            }
        }
    }
    
    public var projectedValue: Binding<Website>? {
        guard let index else { return nil }
        return Binding {
            data.value[index]
        } set: {
            data.value[index] = $0
        }
    }
    
    private var index: Int? {
        data.value.firstIndex(where: { $0.id == self.identifier })
    }
}
