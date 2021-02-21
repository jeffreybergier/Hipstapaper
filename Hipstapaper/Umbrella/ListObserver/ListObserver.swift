//
//  Created by Jeffrey Bergier on 2021/01/31.
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

/// SwiftUI ObservableObject for Lists of items
/// See `FetchedResultsControllerList` for details on how to use.
public protocol ListObserver: ObservableObject {
    associatedtype Collection: RandomAccessCollection
    var data: Collection { get }
}

/// Typeeraser for `ListObserver`
/// See `FetchedResultsControllerList` for details on how to use.
public class AnyListObserver<Collection: RandomAccessCollection>: ListObserver {
    
    public let objectWillChange: ObservableObjectPublisher
    
    public var data: Collection { _data() }
    private let _data: () -> Collection
    
    internal let __testingValue: Any
    
    public init<T: ListObserver>(_ observer: T)
          where T.Collection == Collection,
                T.ObjectWillChangePublisher == ObjectWillChangePublisher
    {
        _data = { observer.data }
        __testingValue = observer
        self.objectWillChange = observer.objectWillChange
    }
}
