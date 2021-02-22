//
//  Created by Jeffrey Bergier on 2021/02/18.
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

public protocol QueueProtocol {
    associatedtype Element
    var isEmpty: Bool { get }
    var peek: Element? { get }
    mutating func append(_: Element)
    mutating func pop() -> Element?
}

public struct Queue<Element>: QueueProtocol, ExpressibleByArrayLiteral {
    
    // TODO: Use a more efficient data storage
    // Internal for testing only
    internal var _storage: [Element] = []
    
    public var isEmpty: Bool {
        return _storage.isEmpty
    }
    
    public var peek: Element? {
        return _storage.first
    }
    
    public init() {}
    
    public init(arrayLiteral elements: Element...) {
        _storage = elements
    }
    
    public mutating func append(_ element: Element) {
        _storage.append(element)
    }
    
    public mutating func append(_ queue: Queue<Element>) {
        _storage += queue._storage
    }
    
    public mutating func removeAll() {
        _storage = []
    }
    
    @discardableResult
    public mutating func pop() -> Element? {
        guard let next = _storage.first else { return nil }
        _storage = Array(_storage.dropFirst())
        return next
    }
}
