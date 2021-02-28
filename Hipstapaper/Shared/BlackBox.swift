//
//  Created by Jeffrey Bergier on 2021/01/17.
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


import Combine

public protocol CacheProtocol: class {
    associatedtype Key: Hashable
    associatedtype Value
    var cache: [Key: Value] { get set }
}

extension CacheProtocol {
    subscript(key: Key, cacheMiss: () -> Value) -> Value {
        if let value = self.cache[key] {
            return value
        }
        let miss = cacheMiss()
        self.cache[key] = miss
        return miss
    }
    subscript(key: Key) -> Value? {
        get { return self.cache[key] }
        set { self.cache[key] = newValue }
    }
}

/// Publishes changes to T through ObjectWillChangePublisher
public class Cache<K: Hashable, V>: ObservableObject, CacheProtocol {
    @Published public var cache: [K: V] = [:]
    public init(initialCache: [K: V] = [:]) {
        self.cache = initialCache
    }
}

/// Never publishes changes through ObjectWillChangePublisher
public class BlackBoxCache<K: Hashable, V>: ObservableObject, CacheProtocol {
    public var cache: [K: V] = [:]
    public init(initialCache: [K: V] = [:]) {
        self.cache = initialCache
    }
}

/// Disconnects the ObservableObjectPublisher from the item
public class BlackBox<Value> {
    public var value: Value
    public init(_ value: Value) {
        self.value = value
    }
}

extension BlackBox: Identifiable where Value: Identifiable {
    public var id: Value.ID {
        return self.value.id
    }
}

extension Set: Identifiable where Element: Identifiable {
    public var id: Element.ID {
        return self.first!.id
    }
}
