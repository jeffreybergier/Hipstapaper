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

public protocol ListProtocol: Swift.RandomAccessCollection, ObservableObject {
    associatedtype Element
}

internal class __List_Empty<T>: ListProtocol {
    
    internal let objectWillChange: ObservableObjectPublisher = .init()

    internal typealias Index = Int
    internal typealias Element = T
    
    // MARK: Swift.Collection Boilerplate
    public var startIndex: Index { 0 }
    public var endIndex: Index { 0 }
    public subscript(index: Index) -> Element { fatalError() }
    public func index(after index: Index) -> Index { 0 }
}
