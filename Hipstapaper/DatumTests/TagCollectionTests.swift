//
//  Created by Jeffrey Bergier on 2020/11/26.
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
import Umbrella
import Datum

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
        tags.__objectDidChange.sink() {
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
        tags.__objectDidChange.sink() {
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
        tags.__objectDidChange.sink() {
            wait2() {
                XCTAssertEqual(tags.data[0].value.name, nil)
                XCTAssertEqual(tags.data[1].value.name, "A")
                XCTAssertEqual(tags.data[2].value.name, "C")
            }
        }.store(in: &self.tokens)
        
        self.wait(for: .short)
    }
}
