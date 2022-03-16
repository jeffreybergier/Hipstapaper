//
//  Created by Jeffrey Bergier on 2022/03/13.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI
import Umbrella
import Collections

public typealias ErrorQueueEnvironment = BlackBox<ErrorQueueCollection>
public typealias ErrorQueueCollection = Deque<UserFacingError>

@propertyWrapper
public struct ErrorQueue: DynamicProperty {
    
    public static func newEnvirementObject() -> ErrorQueueEnvironment {
        return BlackBox(Deque<UserFacingError>(), isObservingValue: true)
    }
    
    @EnvironmentObject public var environment: ErrorQueueEnvironment
    
    public init() {}
    
    public var wrappedValue: UserFacingError? {
        get {
            print("ERRORQ: \(self.environment.value.count)")//
            return self.environment.value.first
        }
        nonmutating set {
            if let newValue = newValue {
                self.environment.value.append(newValue)
            } else {
                guard self.environment.value.isEmpty == false else {
                    "Tried to remove error from queue when it was already empty".log()
                    return
                }
                self.environment.value.removeFirst()
            }
        }
    }
    
    public var projectedValue: Binding<UserFacingError?> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}
