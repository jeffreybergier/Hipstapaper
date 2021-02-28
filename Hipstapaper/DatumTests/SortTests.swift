//
//  Created by Jeffrey Bergier on 2020/11/29.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
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

import XCTest
@testable import Datum

class SortTests: ParentTestCase {
    
    func test_sort() {
        Sort.allCases.forEach() {
            XCTAssertEqual($0.cd_sortDescriptors.count, 1)
            switch $0 {
            case .dateModifiedNewest:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.cd_dateModified))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, false)
            case .dateModifiedOldest:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.cd_dateModified))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, true)
            case .dateCreatedNewest:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.cd_dateCreated))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, false)
            case .dateCreatedOldest:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.cd_dateCreated))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, true)
            case .titleA:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.cd_title))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, true)
            case .titleZ:
                XCTAssertEqual($0.cd_sortDescriptors[0].key, #keyPath(CD_Website.cd_title))
                XCTAssertEqual($0.cd_sortDescriptors[0].ascending, false)
            }
        }
    }
    
}
