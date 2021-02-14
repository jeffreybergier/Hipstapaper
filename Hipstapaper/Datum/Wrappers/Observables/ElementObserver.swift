//
//  Created by Jeffrey Bergier on 2020/11/26.
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

public protocol ElementObserver: ObservableObject, Identifiable, Hashable {
    associatedtype Value
    var value: Value { get }
    var isDeleted: Bool { get }
}

public class AnyElementObserver<Value: Identifiable & Hashable>: ElementObserver {

    public let objectWillChange: ObservableObjectPublisher

    public var value: Value { _value() }
    public var id: Value.ID { _value().id }
    public var isDeleted: Bool { _isDeleted() }
    private var _value: () -> Value
    private var _isDeleted: () -> Bool

    public init<T: ElementObserver>(_ element: T)
    where T.Value == Value,
          T.ID == Value.ID,
          T.ObjectWillChangePublisher == ObservableObjectPublisher
    {
        self._value = { element.value }
        self._isDeleted = { element.isDeleted }
        self.objectWillChange = element.objectWillChange
    }
    
    public static func == (lhs: AnyElementObserver<Value>, rhs: AnyElementObserver<Value>) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
}
