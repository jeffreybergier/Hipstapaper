//
//  Created by Jeffrey Bergier on 2021/02/18.
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

class QueueTests: XCTestCase {

    func test_init() {
        let q: Queue<Int> = [1,2,3]
        XCTAssertEqual(q._storage, [1,2,3])
    }
    
    func test_pop() {
        var q: Queue<Int> = [1,2,3]
        XCTAssertEqual(q.pop()!, 1)
        XCTAssertEqual(q.pop()!, 2)
        XCTAssertEqual(q._storage, [3])
    }
    
    func test_pop_nil() {
        var q: Queue<Int> = [1]
        XCTAssertEqual(q.pop()!, 1)
        XCTAssertNil(q.pop())
    }
    
    func test_append() {
        var q: Queue<Int> = [1,2,3]
        q.append(4)
        XCTAssertEqual(q._storage, [1,2,3,4])
    }

}
