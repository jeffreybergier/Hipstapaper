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
import Umbrella

class FoundationUmbrellaTests: XCTestCase {

    func test_string_trim() {
        XCTAssertNil("".trimmed)
        XCTAssertNil("\n\n\n    \n\n\n\n    \n".trimmed)
        XCTAssertEqual("aString".trimmed, "aString")
        XCTAssertEqual("  \n   aString   \n   ".trimmed, "aString")
        // does interrupt white space in the middle, just the ends
        XCTAssertEqual("  \n   aStr \n ing   \n   ".trimmed, "aStr \n ing")
    }
    
}
