//
//  Created by Jeffrey Bergier on 2021/01/28.
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

import CoreData
import Combine

public protocol SyncMonitor: ObservableObject {
    var isLoggedIn: Bool { get }
    var progress: Progress { get }
    var errorQ: Queue<LocalizedError> { get }
}

public class AnySyncMonitor: SyncMonitor {
    
    public let objectWillChange: ObservableObjectPublisher
    public var isLoggedIn: Bool { _isLoggedIn() }
    public var progress: Progress { _progress() }
    public var errorQ: Queue<LocalizedError> { _errorQ() }
    
    private var _isLoggedIn: () -> Bool
    private var _progress: () -> Progress
    private var _errorQ: () -> Queue<LocalizedError>
    
    public init<T: SyncMonitor>(_ monitor: T) where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        self.objectWillChange = monitor.objectWillChange
        _isLoggedIn = { monitor.isLoggedIn }
        _progress = { monitor.progress }
        _errorQ = { monitor.errorQ }
    }
    
}

public class NoSyncMonitor: SyncMonitor {
    public let isLoggedIn: Bool = false
    public let progress: Progress = .init()
    public let errorQ: Queue<LocalizedError> = []
    public init() {}
}

public class Queue<Element>: ExpressibleByArrayLiteral {
    private var storage: [Element] = []
    public var isEmpty: Bool {
        return self.storage.isEmpty
    }
    required public init(arrayLiteral elements: Element...) {
        self.storage = elements
    }
    public func append(_ newValue: Element) {
        self.storage.append(newValue)
    }
    public func next() -> Element? {
        let next = self.storage.first
        self.storage = Array(self.storage.dropFirst())
        return next
    }
}
