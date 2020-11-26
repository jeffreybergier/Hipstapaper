//
//  Created by Jeffrey Bergier on 2020/11/25.
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

public class AnyCollection<Element>: Collection {

    public let objectWillChange: ObservableObjectPublisher

    public typealias Index = Int
    public typealias Element = Element

    private let _startIndex: () -> Index
    private let _endIndex: () -> Index
    private let _subscript: (Index) -> Element
    private let _indexAfter: (Index) -> Index

    public init<T: Collection>(_ collection: T)
    where T.Element == Element,
          T.Index == Int,
          T.ObjectWillChangePublisher == ObservableObjectPublisher
    {
        _startIndex = { collection.startIndex }
        _endIndex = { collection.endIndex }
        _subscript = { collection[$0] }
        _indexAfter = { collection.index(after: $0) }
        self.objectWillChange = collection.objectWillChange
    }

    // MARK: Swift.Collection Boilerplate
    public var startIndex: Index { _startIndex() }
    public var endIndex: Index { _endIndex() }
    public subscript(index: Index) -> Element { _subscript(index) }
    public func index(after index: Index) -> Index { _indexAfter(index) }

}
