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
public struct TagUserQuery: DynamicProperty {
    
    // TODO: Hook up core data
    @ObservedObject private var _data = tagEnvironment
    @State public var identifier: Tag.Identifier?
    
    public init() { }
    
    public var wrappedValue: Tag? {
        get { index.map { _data.value[$0] }}
        nonmutating set {
            guard let index else { return }
            if let newValue {
                _data.value[index] = newValue
            } else {
                _data.value.remove(at: index)
            }
        }
    }
    
    public var projectedValue: Binding<Tag>? {
        guard let index else { return nil }
        return Binding {
            _data.value[index]
        } set: {
            _data.value[index] = $0
        }
    }
    
    private var index: Int? {
        _data.value.firstIndex(where: { $0.id == self.identifier })
    }
}
