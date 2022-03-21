//
//  Created by Jeffrey Bergier on 2020/11/26.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
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
        self.wait(for: .short)
    }
}
