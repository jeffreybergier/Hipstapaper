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

internal class WebsiteCollectionTests : ParentTestCase {
    
    override internal func setUpWithError() throws {
        try super.setUpWithError()
        
        try Array<String>(["A", "B", "C", "D"]).enumerated().forEach {
            _ = try self.controller.createWebsite(.init(
                title: $0.element,
                originalURL: URL(string: "http://\($0.element).com/original"),
                resolvedURL: URL(string: "http://\($0.element).com/resolved"),
                isArchived: $0.offset.isMultiple(of: 2),
                thumbnail: nil
            )).get()
        }
    }
    
    // MARK: Read
    
    internal func test_collection_read_all() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .dateCreatedNewest)
        ).get()
        XCTAssertEqual(sites.data.count, 4)
    }
    
    internal func test_collection_read_unarchived() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .unarchived, sort: .dateCreatedNewest)
        ).get()
        XCTAssertEqual(sites.data.count, 2)
    }
    
    internal func test_collection_read_sort_titleA() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .titleA)
        ).get()
        XCTAssertEqual(sites.data[0].value.title, "A")
        XCTAssertEqual(sites.data[3].value.title, "D")
    }
    
    internal func test_collection_read_sort_titleZ() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .all,
                                                                  sort: .titleZ)).get()
        XCTAssertEqual(sites.data[0].value.title, "D")
        XCTAssertEqual(sites.data[3].value.title, "A")
    }
    
    internal func test_collection_read_sort_modifiedNew() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .dateModifiedNewest)
        ).get()
        XCTAssertEqual(sites.data[0].value.title, "D")
        XCTAssertEqual(sites.data[3].value.title, "A")
    }
    
    internal func test_collection_read_sort_modifiedOld() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .dateModifiedOldest)
        ).get()
        XCTAssertEqual(sites.data[0].value.title, "A")
        XCTAssertEqual(sites.data[3].value.title, "D")
    }
    
    internal func test_collection_read_sort_createdNew() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .dateCreatedNewest)
        ).get()
        XCTAssertEqual(sites.data[0].value.title, "D")
        XCTAssertEqual(sites.data[3].value.title, "A")
    }
    
    internal func test_collection_read_sort_createdOld() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .dateCreatedOldest)
        ).get()
        XCTAssertEqual(sites.data[0].value.title, "A")
        XCTAssertEqual(sites.data[3].value.title, "D")
    }
    
    // MARK: Create
    
    internal func test_collection_create() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .dateCreatedNewest)
        ).get()
        XCTAssertEqual(sites.data.count, 4)
        _ = try self.controller.createWebsite(.init(title: "Z",
                                              originalURL: nil,
                                              resolvedURL: nil,
                                              isArchived: false,
                                              thumbnail: nil)).get()
        XCTAssertEqual(sites.data.count, 5)
    }
    
    func test_collection_create_observation() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .dateCreatedNewest)
        ).get()
        XCTAssertEqual(sites.data.count, 4)
        self.do(after: .instant) {
            do {
                _ = try self.controller.createWebsite(.init(title: "Z")).get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        
        // verify objectWillChange fires and collection is unchanged
        let wait1 = self.newWait()
        sites.objectWillChange.sink() {
            wait1() { XCTAssertEqual(sites.data.count, 4) }
        }.store(in: &self.tokens)
        
        let wait2 = self.newWait()
        let _tags = sites.__testingValue as! CD_Observer<AnyElement<AnyWebsite>, CD_Website>
        _tags.__objectDidChange.sink() {
            wait2() { XCTAssertEqual(sites.data.count, 5) }
        }.store(in: &self.tokens)
        
        self.wait(for: .short)
    }
    
    // MARK: Update
    
    internal func test_collection_update() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .titleA)
        ).get()
        XCTAssertEqual(sites.data[0].value.title, "A")
        try self.controller.update([sites.data[0]], .init(title: "Z")).get()
        XCTAssertEqual(sites.data[0].value.title, "B")
        XCTAssertEqual(sites.data[3].value.title, "Z")
    }
    
    func test_collection_update_observation() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .titleA)
        ).get()
        XCTAssertEqual(sites.data[0].value.title, "A")
        XCTAssertEqual(sites.data[1].value.title, "B")
        XCTAssertEqual(sites.data[2].value.title, "C")
        XCTAssertEqual(sites.data[3].value.title, "D")
        self.do(after: .instant) {
            do {
                try self.controller.update([sites.data[0]], .init(title: "Z")).get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        let wait1 = self.newWait()
        sites.objectWillChange.sink() {
            wait1() {
                XCTAssertEqual(sites.data[0].value.title, "Z")
                XCTAssertEqual(sites.data[1].value.title, "B")
                XCTAssertEqual(sites.data[2].value.title, "C")
                XCTAssertEqual(sites.data[3].value.title, "D")
            }
        }.store(in: &self.tokens)
        
        let wait2 = self.newWait()
        let _tags = sites.__testingValue as! CD_Observer<AnyElement<AnyWebsite>, CD_Website>
        _tags.__objectDidChange.sink() {
            wait2() {
                XCTAssertEqual(sites.data[0].value.title, "B")
                XCTAssertEqual(sites.data[1].value.title, "C")
                XCTAssertEqual(sites.data[2].value.title, "D")
                XCTAssertEqual(sites.data[3].value.title, "Z")
            }
        }.store(in: &self.tokens)
        
        self.wait(for: .short)
    }
    
    // MARK: Delete
    
    internal func test_collection_delete() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .titleA)
        ).get()
        XCTAssertEqual(sites.data.count, 4)
        XCTAssertEqual(sites.data[0].value.title, "A")
        try self.controller.delete([sites.data[0]]).get()
        XCTAssertEqual(sites.data.count, 3)
        XCTAssertEqual(sites.data[0].value.title, "B")
        XCTAssertEqual(sites.data[2].value.title, "D")
    }
    
    func test_collection_delete_observation() throws {
        let sites = try self.controller.readWebsites(
            query: .init(isArchived: .all, sort: .titleA)
        ).get()
        XCTAssertEqual(sites.data[0].value.title, "A")
        XCTAssertEqual(sites.data[1].value.title, "B")
        XCTAssertEqual(sites.data[2].value.title, "C")
        XCTAssertEqual(sites.data[3].value.title, "D")
        self.do(after: .instant) {
            do {
                try self.controller.delete([sites.data[0]]).get()
            } catch {
                XCTFail(String(describing: error))
            }
        }
        let wait1 = self.newWait()
        sites.objectWillChange.sink() {
            wait1() {
                XCTAssertEqual(sites.data[0].value.title, "A")
                XCTAssertEqual(sites.data[1].value.title, "B")
                XCTAssertEqual(sites.data[2].value.title, "C")
                XCTAssertEqual(sites.data[3].value.title, "D")
                XCTAssertTrue(sites.data[0].isDeleted)
            }
        }.store(in: &self.tokens)
        
        let wait2 = self.newWait()
        let _tags = sites.__testingValue as! CD_Observer<AnyElement<AnyWebsite>, CD_Website>
        _tags.__objectDidChange.sink() {
            wait2() {
                XCTAssertEqual(sites.data[0].value.title, "B")
                XCTAssertEqual(sites.data[1].value.title, "C")
                XCTAssertEqual(sites.data[2].value.title, "D")
            }
        }.store(in: &self.tokens)
        
        self.wait(for: .short)
    }
}
