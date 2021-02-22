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

class MappedListTests: AsyncTestCase {
    
    func test_lazy_mapping() {
        let data = [1,3,5,9,20]
        let wait = self.newWait(count: 3)
        let lazyMap: MappedList<Int, String> = MappedList(data) { input in
            wait() {
                XCTAssertNotEqual(input, 3)
                XCTAssertNotEqual(input, 5)
            }
            return String(input * 2)
        }
        self.do(after: .instant) {
            let item = lazyMap[0]
            XCTAssertEqual(item.0, 1)
            XCTAssertEqual(item.1, "2")
        }
        self.do(after: .short) {
            let item = lazyMap[3]
            XCTAssertEqual(item.0, 9)
            XCTAssertEqual(item.1, "18")
        }
        self.do(after: .short) {
            let item = lazyMap[4]
            XCTAssertEqual(item.0, 20)
            XCTAssertEqual(item.1, "40")
        }
        self.wait(for: .medium)
    }
    
}
