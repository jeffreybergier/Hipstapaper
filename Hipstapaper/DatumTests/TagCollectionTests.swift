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
@testable import Datum

class TagCollectionTests: ParentTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        _ = try self.controller.createTag(name: "B").get()
        _ = try self.controller.createTag(name: "A").get()
        _ = try self.controller.createTag(name: "C").get()
        _ = try self.controller.createTag(name: nil).get()
    }

    // MARK: Read

    func test_collection_read() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.data.count, 4)
        XCTAssertEqual(tags.data[0].value.name, nil)
        XCTAssertEqual(tags.data[1].value.name, "A")
        XCTAssertEqual(tags.data[2].value.name, "B")
        XCTAssertEqual(tags.data[3].value.name, "C")
    }

    // MARK: Create

    func test_collection_create() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.data.count, 4)
        _ = try self.controller.createTag(name: "New").get()
        XCTAssertEqual(tags.data.count, 5)
    }

    func test_collection_create_observation() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.data.count, 4)
        self.do(after: .instant) {
            do {
                _ = try self.controller.createTag(name: "New").get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        
        // verify objectWillChange fires and collection is unchanged
        let wait1 = self.newWait()
        tags.objectWillChange.sink() {
            wait1() { XCTAssertEqual(tags.data.count, 4) }
        }.store(in: &self.tokens)
        
        // verify data does actually change
        let wait2 = self.newWait()
        let _tags = tags.__testingValue as! CD_Observer<AnyElement<AnyTag>, CD_Tag>
        _tags.__objectDidChange.sink() {
            wait2() { XCTAssertEqual(tags.data.count, 5) }
        }.store(in: &self.tokens)
        
        self.wait(for: .short)
    }

    // MARK: Update

    func test_collection_update() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.data[0].value.name, nil)
        XCTAssertEqual(tags.data[1].value.name, "A")
        XCTAssertEqual(tags.data[2].value.name, "B")
        XCTAssertEqual(tags.data[3].value.name, "C")
        try self.controller.update(tags.data[2], name: "Z").get()
        XCTAssertEqual(tags.data[0].value.name, nil)
        XCTAssertEqual(tags.data[1].value.name, "A")
        XCTAssertEqual(tags.data[2].value.name, "C")
        XCTAssertEqual(tags.data[3].value.name, "Z")
    }

    func test_collection_update_observation() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.data[0].value.name, nil)
        XCTAssertEqual(tags.data[1].value.name, "A")
        XCTAssertEqual(tags.data[2].value.name, "B")
        XCTAssertEqual(tags.data[3].value.name, "C")
        self.do(after: .instant) {
            do {
                try self.controller.update(tags.data[2], name: "Z").get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        
        // verify objectWillChange fires and collection is unchanged
        let wait1 = self.newWait()
        tags.objectWillChange.sink() {
            wait1() {
                XCTAssertEqual(tags.data[0].value.name, nil)
                XCTAssertEqual(tags.data[1].value.name, "A")
                XCTAssertEqual(tags.data[2].value.name, "Z")
                XCTAssertEqual(tags.data[3].value.name, "C")
            }
        }.store(in: &self.tokens)
        
        // verify data does actually change
        let wait2 = self.newWait()
        let _tags = tags.__testingValue as! CD_Observer<AnyElement<AnyTag>, CD_Tag>
        _tags.__objectDidChange.sink() {
            wait2() {
                XCTAssertEqual(tags.data[0].value.name, nil)
                XCTAssertEqual(tags.data[1].value.name, "A")
                XCTAssertEqual(tags.data[2].value.name, "C")
                XCTAssertEqual(tags.data[3].value.name, "Z")
            }
        }.store(in: &self.tokens)
        
        self.wait(for: .short)
    }

    // MARK: Delete

    func test_collection_delete() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.data[0].value.name, nil)
        XCTAssertEqual(tags.data[1].value.name, "A")
        XCTAssertEqual(tags.data[2].value.name, "B")
        XCTAssertEqual(tags.data[3].value.name, "C")
        try self.controller.delete(tags.data[2]).get()
        XCTAssertEqual(tags.data[0].value.name, nil)
        XCTAssertEqual(tags.data[1].value.name, "A")
        XCTAssertEqual(tags.data[2].value.name, "C")
    }

    func test_collection_delete_observation() throws {
        let tags = try self.controller.readTags().get()
        XCTAssertEqual(tags.data[0].value.name, nil)
        XCTAssertEqual(tags.data[1].value.name, "A")
        XCTAssertEqual(tags.data[2].value.name, "B")
        XCTAssertEqual(tags.data[3].value.name, "C")
        self.do(after: .instant) {
            do {
                try self.controller.delete(tags.data[2]).get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        
        // verify objectWillChange fires and collection is unchanged
        let wait1 = self.newWait()
        tags.objectWillChange.sink() {
            wait1() {
                XCTAssertEqual(tags.data[0].value.name, nil)
                XCTAssertEqual(tags.data[1].value.name, "A")
                XCTAssertEqual(tags.data[2].value.name, "B")
                XCTAssertEqual(tags.data[3].value.name, "C")
                XCTAssertTrue(tags.data[2].isDeleted)
            }
        }.store(in: &self.tokens)
        
        // verify data does actually change
        let wait2 = self.newWait()
        let _tags = tags.__testingValue as! CD_Observer<AnyElement<AnyTag>, CD_Tag>
        _tags.__objectDidChange.sink() {
            wait2() {
                XCTAssertEqual(tags.data[0].value.name, nil)
                XCTAssertEqual(tags.data[1].value.name, "A")
                XCTAssertEqual(tags.data[2].value.name, "C")
            }
        }.store(in: &self.tokens)
        
        self.wait(for: .short)
    }
}
