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

/// Represents the progress of something that is long running and can produce
/// errors upon startup and errors while running. I use this to reflect the status
/// of NSPersistentCloudKitContainer sync. But its generic enough to be used for
/// many types of long-running / background processes.
/// Use `AnyContinousProgress` to get around AssociatedType compile errors.
public protocol ContinousProgress: ObservableObject {
    /// Fixed error that only occurs on startup and doesn't change
    /// for the lifetime of the process.
    var initializeError: UserFacingError? { get }
    var progress: Progress { get }
    /// When an error occurs, append it to the Queue.
    var errorQ: ErrorQueue { get set }
}

public class AnyContinousProgress: ContinousProgress {
    
    public let objectWillChange: ObservableObjectPublisher
    public var initializeError: UserFacingError? { _initializeError() }
    public var progress: Progress { _progress() }
    public var errorQ: ErrorQueue {
        get { _errorQ_get() }
        set { _errorQ_set(newValue) }
    }
    
    private var _initializeError: () -> UserFacingError?
    private var _progress: () -> Progress
    private var _errorQ_get: () -> ErrorQueue
    private var _errorQ_set: (ErrorQueue) -> Void
    
    public init<T: ContinousProgress>(_ progress: T) where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        self.objectWillChange = progress.objectWillChange
        _initializeError      = { progress.initializeError }
        _progress             = { progress.progress }
        _errorQ_get           = { progress.errorQ }
        _errorQ_set           = { progress.errorQ = $0 }
    }
}

/// Use when you have no progress to report
public class NoContinousProgress: ContinousProgress {
    public let initializeError: UserFacingError? = nil
    public let progress: Progress = .init()
    public var errorQ: ErrorQueue = .init()
    public init() {}
}
