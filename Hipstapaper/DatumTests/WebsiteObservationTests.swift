//
//  Created by Jeffrey Bergier on 2020/11/30.
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

class WebsiteObservationTests: ParentTestCase {

    func test_website_update_observation() throws {
        let website = try self.controller.createWebsite(.init(title: "A")).get()
        XCTAssertEqual(website.value.title, "A")
        self.do(after: .instant) {
            do {
                try self.controller.update([website], .init(title: "B")).get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        let wait = self.newWait(count: 3)
        self.token = website.objectWillChange.sink() {
            wait() {
                XCTAssertEqual(website.value.title, "B")
                XCTAssertFalse(website.isDeleted)
            }
        }
        self.wait(for: .short)
    }

    func test_website_delete_observation() throws {
        let website = try self.controller.createWebsite(.init(title: "A")).get()
        XCTAssertEqual(website.value.title, "A")
        self.do(after: .instant) {
            do {
                try self.controller.delete(website).get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        let wait = self.newWait()
        self.token = website.objectWillChange.sink() {
            wait() {
                XCTAssertTrue(website.isDeleted)
            }
        }
        self.wait(for: .short)
    }
}
