//
//  Created by Jeffrey Bergier on 2021/01/17.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
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
