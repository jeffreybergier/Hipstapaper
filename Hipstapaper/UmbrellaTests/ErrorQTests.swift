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

class ErrorQTests: XCTestCase {
    
    func test_next() {
        var q = _ErrorQ<Int>()
        q.append(1)
        XCTAssertEqual(q.next()!, 1)
        XCTAssertNil(q.next())
    }
    
    func test_append_raw() {
        var q = _ErrorQ<Int>()
        q.append(1)
        q.append(2)
        q.append(3)
        XCTAssertEqual(q.next()!, 1)
        XCTAssertEqual(q.next()!, 2)
        XCTAssertEqual(q.next()!, 3)
        XCTAssertNil(q.next())
    }
    
    func test_append_failure() {
        var q = _ErrorQ<Int>()
        let rO: Result<String, Int> = .failure(3)
        let rT = q.append(rO)
        XCTAssertEqual(rO, rT)
        XCTAssertEqual(q.next()!, 3)
        XCTAssertNil(q.next())
    }
    
    func test_append_success() {
        var q = _ErrorQ<Int>()
        let rO: Result<Int, String> = .success(4)
        let rT = q.append(rO)
        XCTAssertEqual(rO, rT)
        XCTAssertEqual(q.next()!, 4)
        XCTAssertNil(q.next())
    }
}

extension Int: Error {}
extension String: Error {}
