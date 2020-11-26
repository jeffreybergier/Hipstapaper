//
//  Created by Jeffrey Bergier on 2020/11/26.
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
import Datum

class TagCollectionTests: ParentTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        try self.controller.createTag(name: "B").get()
        try self.controller.createTag(name: "A").get()
        try self.controller.createTag(name: "C").get()
        try self.controller.createTag(name: nil).get()
    }

    func test_collection_load() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.count, 4)
        XCTAssertEqual(tags[0].item.name, nil)
        XCTAssertEqual(tags[1].item.name, "A")
        XCTAssertEqual(tags[2].item.name, "B")
        XCTAssertEqual(tags[3].item.name, "C")
    }

}
