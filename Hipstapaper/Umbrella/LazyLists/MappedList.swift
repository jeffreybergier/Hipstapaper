//
//  Created by Jeffrey Bergier on 2020/12/19.
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

public struct MappedList<E, U>: RandomAccessCollection {
    
    public typealias Index = Int
    public typealias Element = (E, U)

    private let _startIndex: () -> Index
    private let _endIndex: () -> Index
    private let _subscript: (Index) -> E
    private let transform: (E) -> U

    public init<T: RandomAccessCollection>(_ collection: T, transform: @escaping (E) -> U)
    where T.Element == E,
          T.Index == Int
    {
        _startIndex = { collection.startIndex }
        _endIndex = { collection.endIndex }
        _subscript = { collection[$0] }
        self.transform = transform
    }

    // MARK: Swift.Collection Boilerplate
    public var startIndex: Index { _startIndex() }
    public var endIndex: Index { _endIndex() }
    public subscript(index: Index) -> Element {
        let e = _subscript(index)
        let u = transform(e)
        return (e, u)
    }
}
