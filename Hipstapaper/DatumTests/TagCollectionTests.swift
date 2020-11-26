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
import Combine

class TagCollectionTests: ParentTestCase {

    private var token: AnyCancellable?

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
        XCTAssertEqual(tags[0].value.name, nil)
        XCTAssertEqual(tags[1].value.name, "A")
        XCTAssertEqual(tags[2].value.name, "B")
        XCTAssertEqual(tags[3].value.name, "C")
    }

    func test_collection_update() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.count, 4)
        try self.controller.createTag(name: "New").get()
        XCTAssertEqual(tags.count, 5)
    }

    func test_collection_update_observation() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.count, 4)
        self.do(after: .short) {
            do {
                try self.controller.createTag(name: "New").get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        let wait = self.newWait()
        self.token = tags.objectWillChange.sink() {
            wait() { XCTAssertEqual(tags.count, 5) }
        }
        self.wait(for: .long)
    }
}
