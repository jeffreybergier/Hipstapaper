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

class TagObservationTests: ParentTestCase {

    func test_tag_update_observation() throws {
        let tag = try self.controller.createTag(name: "A").get()
        XCTAssertEqual(tag.value.name, "A")
        self.do(after: .instant) {
            do {
                try self.controller.update(tag, name: "B").get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        let wait = self.newWait()
        tag.objectWillChange.sink() {
            wait() {
                XCTAssertEqual(tag.value.name, "B")
                XCTAssertFalse(tag.isDeleted)
            }
        }.store(in: &self.tokens)
        self.wait(for: .short)
    }

    func test_tag_delete_observation() throws {
        let tag = try self.controller.createTag(name: "A").get()
        XCTAssertEqual(tag.value.name, "A")
        self.do(after: .instant) {
            do {
                try self.controller.delete(tag).get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        let wait = self.newWait()
        tag.objectWillChange.sink() {
            wait() {
                XCTAssertTrue(tag.isDeleted)
            }
        }.store(in: &self.tokens)
        self.wait(for: .medium)
    }
}
