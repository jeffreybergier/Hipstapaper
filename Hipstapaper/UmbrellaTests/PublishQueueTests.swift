//
//  Created by Jeffrey Bergier on 2021/02/22.
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

import XCTest
@testable import Umbrella

class PublishQueueTests: AsyncTestCase {

    func test_publish_initial() {
        let queue = PublishQueue<Int>()
        let wait = self.newWait(count: 1)
        queue.$current.sink { newValue in
            wait() { XCTAssertNil(newValue?.value) }
        }.store(in: &self.tokens)
        self.wait(for: .short)
    }
    
    func test_publish_append() {
        let queue = PublishQueue<Int>()
        let wait = self.newWait(count: 2)
        var hitOnce = false
        queue.$current.sink { newValue in
            wait() {
                if hitOnce {
                    XCTAssertEqual(newValue?.value, 5)
                } else {
                    XCTAssertNil(newValue?.value)
                }
            }
            hitOnce = true
        }.store(in: &self.tokens)
        queue.queue.append(5)
        self.wait(for: .short)
    }
    
    // when swiftUI dismisses the alert / sheet
    // it automatically sets the binding to nil
    // the queue is expected to fill it with the next item
    // if there is another item.
    func test_publish_swiftUI_dequeue() {
        let queue = PublishQueue<Int>()
        let wait = self.newWait(count: 5)
        var hitCount = 0
        queue.$current.sink { newValue in
            wait() {
                switch hitCount {
                case 0:
                    XCTAssertNil(newValue?.value)
                case 1:
                    XCTAssertEqual(newValue?.value, 5)
                case 2:
                    XCTAssertNil(newValue?.value)
                case 3:
                    XCTAssertEqual(newValue?.value, 10)
                case 4:
                    XCTAssertNil(newValue?.value)
                default:
                    XCTFail()
                }
            }
            hitCount += 1
        }.store(in: &self.tokens)
        
        queue.queue.append(5)
        queue.queue.append(10)
        self.do(after: .short) {
            // after this 10 should appear
            queue.current = nil
        }
        self.do(after: .medium) {
            // after this nil should stay as there are no more items
            queue.current = nil
        }
        
        self.wait(for: .long)
    }
    
}
