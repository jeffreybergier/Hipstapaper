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

// TODO: Move this to umbrella
@propertyWrapper
public struct SceneCodable<Value: Codable>: DynamicProperty {
    
    @SceneStorage private var storage: String?
    
    @State private var encoder = PropertyListEncoder()
    @State private var decoder = PropertyListDecoder()
    
    // TODO: Not sure if cache actually helps
    @State private var cache: [String: Value] = [:]
    
    public init(_ key: String) {
        _storage = .init(key)
    }
    
    public var wrappedValue: Value? {
        get { self.read() }
        nonmutating set { self.write(newValue) }
    }
    
    private func write(_ newValue: Value?) {
        let data = try? self.encoder.encode(newValue)
        let string = data?.base64EncodedString()
        if let string = string {
            self.cache[string] = newValue
        }
        self.storage = string
    }
    private func read() -> Value? {
        let string = self.storage ?? ""
        if let cache = self.cache[string] {
            return cache
        }
        let data = Data(base64Encoded: string) ?? Data()
        let value = try? self.decoder.decode(Value.self, from: data)
        return value
    }
}
