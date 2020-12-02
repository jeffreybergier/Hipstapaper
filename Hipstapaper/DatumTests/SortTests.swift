//
//  Created by Jeffrey Bergier on 2020/11/29.
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

import XCTest
@testable import Datum

class SortTests: ParentTestCase {
    
    func test_sort() {
        Sort.allCases.forEach() {
            XCTAssertEqual($0.cd_sortDescriptors.count, 1)
            switch $0 {
            case .dateModifiedNewest:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.dateModified))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, true)
            case .dateModifiedOldest:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.dateModified))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, false)
            case .dateCreatedNewest:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.dateCreated))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, true)
            case .dateCreatedOldest:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.dateCreated))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, false)
            case .titleA:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.title))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, true)
            case .titleZ:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.title))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, false)
            }
        }
    }
    
}
