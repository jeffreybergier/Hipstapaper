//
//  Created by Jeffrey Bergier on 2020/08/22.
//
//  MIT License
//
//  Copyright (c) 2020 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//

import Combine
import XCTest

internal class AsyncTestCase: AsyncDeprecateTestCase {
    
    public var tokens: Set<AnyCancellable> = []
    
    public enum Delay: TimeInterval {
        case instant = 0.0, short = 0.1, medium = 0.5, long = 1.0, superLong = 10.0
    }
    
    public typealias FulfillClosure = (((() -> Void)?) -> Void)
    
    /// Execute this closure to fulfill the `XCTestExpectation`
    /// Also, pass in a new closure to execute validation tests before fulfilling
    /// Also, this is all guaranteed to happen on the main thread as required by`XCTAssert`.
    public func newWait(description: String = "🤷‍♀️",
                        count: Int = 1)
    -> FulfillClosure
    {
        let wait = self.expectation(description: description)
        wait.expectedFulfillmentCount = count
        return { innerClosure in
            let work = {
                innerClosure?()
                wait.fulfill()
            }
            guard !Thread.isMainThread else { work(); return; }
            DispatchQueue.main.sync(execute: work)
        }
    }
    
    /// Stupid helper to run the work on the main thread if needed
    public func main(_ work: (() -> Void)) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
    
    public func `do`(after delay: Delay,
                     description: String = "🤷‍♀️",
                     work: @escaping () -> Void)
    {
        let wait = self.newWait(description: description)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay.rawValue) {
            wait(work)
        }
    }
    
    public func wait(for delay: Delay) {
        self.waitForExpectations(timeout: delay.rawValue, handler: nil)
    }
}

public class AsyncDeprecateTestCase: XCTestCase {
    @available(*, deprecated, message:"Use `wait(forDelay:)` or other variant in combination with `newWait()`")
    override public func wait(for waits: [XCTestExpectation],
                              timeout: TimeInterval)
    {
        super.wait(for: waits, timeout: timeout)
    }
    
    @available(*, deprecated, message:"Use `wait(forDelay:)` or other variant in combination with `newWait()`")
    override public func wait(for: [XCTestExpectation],
                              timeout: TimeInterval,
                              enforceOrder: Bool)
    {
        super.wait(for: `for`, timeout: timeout, enforceOrder: enforceOrder)
    }
    
    @available(*, deprecated, message:"Use `wait(forDelay:)` or other variant in combination with `newWait()`")
    override public func waitForExpectations(timeout: TimeInterval,
                                             handler: XCWaitCompletionHandler? = nil)
    {
        super.waitForExpectations(timeout: timeout, handler: handler)
    }
}
