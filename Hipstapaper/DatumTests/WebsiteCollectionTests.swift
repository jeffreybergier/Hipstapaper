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

internal class WebsiteCollectionTests : ParentTestCase {
    
    override internal func setUpWithError() throws {
        try super.setUpWithError()
        
        try Array<String>(["A", "B", "C", "D"]).enumerated().forEach {
            _ = try self.controller.createWebsite(
                title: $0.element,
                originalURL: URL(string: "http://\($0.element).com/original"),
                resolvedURL: URL(string: "http://\($0.element).com/resolved"),
                isArchived: $0.offset.isMultiple(of: 2),
                thumbnail: nil
            ).get()
        }
    }
    
    // MARK: Read
    
    internal func test_collection_read_all() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .all),
                                                     sort: .dateCreatedNewest).get()
        XCTAssertEqual(sites.count, 4)
    }
    
    internal func test_collection_read_unarchived() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .unarchived),
                                                     sort: .dateCreatedNewest).get()
        XCTAssertEqual(sites.count, 2)
    }
    
    internal func test_collection_read_sort_titleA() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .all),
                                                     sort: .titleA).get()
        XCTAssertEqual(sites[0].value.title, "A")
        XCTAssertEqual(sites[3].value.title, "D")
    }
    
    internal func test_collection_read_sort_titleZ() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .all),
                                                     sort: .titleZ).get()
        XCTAssertEqual(sites[0].value.title, "D")
        XCTAssertEqual(sites[3].value.title, "A")
    }
    
    internal func test_collection_read_sort_modifiedNew() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .all),
                                                     sort: .dateModifiedNewest).get()
        XCTAssertEqual(sites[0].value.title, "A")
        XCTAssertEqual(sites[3].value.title, "D")
    }
    
    internal func test_collection_read_sort_modifiedOld() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .all),
                                                     sort: .dateModifiedOldest).get()
        XCTAssertEqual(sites[0].value.title, "D")
        XCTAssertEqual(sites[3].value.title, "A")
    }
    
    internal func test_collection_read_sort_createdNew() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .all),
                                                     sort: .dateCreatedNewest).get()
        XCTAssertEqual(sites[0].value.title, "A")
        XCTAssertEqual(sites[3].value.title, "D")
    }
    
    internal func test_collection_read_sort_createdOld() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .all),
                                                     sort: .dateCreatedOldest).get()
        XCTAssertEqual(sites[0].value.title, "D")
        XCTAssertEqual(sites[3].value.title, "A")
    }
    
    // MARK: Create
    
    internal func test_collection_create() throws {
        let sites = try self.controller.readWebsites(query: .init(isArchived: .all),
                                                     sort: .dateCreatedNewest).get()
        XCTAssertEqual(sites.count, 4)
        _ = try self.controller.createWebsite(title: "Z",
                                              originalURL: nil,
                                              resolvedURL: nil,
                                              isArchived: false,
                                              thumbnail: nil).get()
        XCTAssertEqual(sites.count, 5)
    }
    
    // MARK: Update
    
    internal func test_collection_update() throws {
        
    }
    
    internal func test_collection_update_observation() throws {
        
    }
    
    // MARK: Delete
    
    internal func test_collection_delete() throws {
        
    }
    
    internal func test_collection_delete_observation() throws {
        
    }
}
