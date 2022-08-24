//
//  Created by Jeffrey Bergier on 2022/08/23.
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

/// Provides a SceneStorage API that takes any codable value
@propertyWrapper
public struct JSBSceneStorage<Value: Codable>: DynamicProperty {
    
    // MARK: Property Wrapper Boilerplate
    
    private let defaultValue: Value
    @SceneStorage private var storage: String?
    
    public init(wrappedValue: Value, _ key: String) {
        _storage = .init(key)
        self.defaultValue = wrappedValue
    }
    
    public var wrappedValue: Value {
        get { self.read() ?? self.defaultValue }
        nonmutating set { self.write(newValue) }
    }
    
    public var projectedValue: Binding<Value> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    
    // MARK: Encoding / Decoding
    
    // Not sure if storing these helps performance
    @State private var encoder = PropertyListEncoder()
    @State private var decoder = PropertyListDecoder()
    
    // Not sure if cache actually helps performance
    @State private var cache: [String: Value] = [:]
    
    private func read() -> Value? {
        guard let string = self.storage else { return nil }
        if let cache = self.cache[string] { return cache }
        guard let data = Data(base64Encoded: string) else { return nil }
        return try? self.decoder.decode(Value.self, from: data)
    }
    
    private func write(_ newValue: Value?) {
        let data = try? self.encoder.encode(newValue)
        let string = data?.base64EncodedString()
        self.storage = string
        guard let string = string else { return }
        self.cache[string] = newValue
    }
}
