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

public struct Queue<Element>: ExpressibleByArrayLiteral {
    // TODO: Use a more efficient data storage
    // Internal for testing only
    internal var _storage: [Element] = []
    public init() {}
    public init(arrayLiteral elements: Element...) {
        _storage = elements
    }
    public mutating func append(_ element: Element) {
        _storage.append(element)
    }
    public mutating func pop() -> Element? {
        guard let next = _storage.first else { return nil }
        _storage = Array(_storage.dropFirst())
        return next
    }
}

public struct _ErrorQ<Element> {
    
    private var _storage: Queue<Element> = []
    
    public mutating func next() -> Element? {
        return _storage.pop()
    }
    
    public mutating func append(_ element: Element) {
        return _storage.append(element)
    }
    
    @discardableResult
    public mutating func append<Ignored>(_ result: Result<Ignored, Element>) -> Result<Ignored, Element>
    {
        guard case .failure(let element) = result else { return result }
        _storage.append(element)
        return result
    }
    
    @discardableResult
    public mutating func append<Ignored>(_ result: Result<Element, Ignored>) -> Result<Element, Ignored>
    {
        guard case .success(let element) = result else { return result }
        _storage.append(element)
        return result
    }
}
