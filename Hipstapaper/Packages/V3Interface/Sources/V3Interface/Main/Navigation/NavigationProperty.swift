//
//  Created by Jeffrey Bergier on 2022/06/28.
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
import V3Model

@propertyWrapper
internal struct Navigation: DynamicProperty {
    
    @SceneStorage("com.hipstapaper.nav") private var storage: String?
    
    @State private var encoder = PropertyListEncoder()
    @State private var decoder = PropertyListDecoder()
    
    internal var wrappedValue: Value {
        get { self.read() }
        nonmutating set { self.write(newValue) }
    }
    
    internal var projectedValue: Binding<Value> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    
    private func write(_ newValue: Value) {
        let box = CodableBox(value: newValue)
        let data = try? self.encoder.encode(box)
        self.storage = data?.base64EncodedString()
    }
    private func read() -> Value {
        let data = Data(base64Encoded: self.storage ?? "") ?? Data()
        let box = try? self.decoder.decode(CodableBox.self, from: data)
        return box?.value ?? .init()
    }
    
}

fileprivate struct CodableBox: Codable {
    fileprivate var value: Navigation.Value
}
