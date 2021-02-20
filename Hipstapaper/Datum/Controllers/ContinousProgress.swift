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

import Combine
import CoreData
import Umbrella

public protocol ContinousProgress: ObservableObject {
    // TODO: Change this to `persistentError`
    var isLoggedIn: Bool { get }
    var progress: Progress { get }
    // TODO: Change this to ephemeralError?
    var errorQ: ErrorQueue { get set }
}

public class AnyContinousProgress: ContinousProgress {
    
    public let objectWillChange: ObservableObjectPublisher
    public var isLoggedIn: Bool { _isLoggedIn() }
    public var progress: Progress { _progress() }
    public var errorQ: ErrorQueue {
        get { _errorQ_get() }
        set { _errorQ_set(newValue) }
    }
    
    private var _isLoggedIn: () -> Bool
    private var _progress: () -> Progress
    private var _errorQ_get: () -> ErrorQueue
    private var _errorQ_set: (ErrorQueue) -> Void
    
    public init<T: ContinousProgress>(_ monitor: T) where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        self.objectWillChange = monitor.objectWillChange
        _isLoggedIn = { monitor.isLoggedIn }
        _progress = { monitor.progress }
        _errorQ_get = { monitor.errorQ }
        _errorQ_set = { monitor.errorQ = $0 }
    }
    
}

public class NoContinousProgress: ContinousProgress {
    public let isLoggedIn: Bool = false
    public let progress: Progress = .init()
    public var errorQ: ErrorQueue = .init()
    public init() {}
}
