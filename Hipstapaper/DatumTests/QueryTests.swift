//
//  Created by Jeffrey Bergier on 2020/11/28.
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
import CoreData
@testable import Datum

class QueryTests: ParentTestCase {
    
    func test_predicate_all() throws {
        let query = Query(isArchived: .all, tag: nil, search: nil)
        XCTAssertNil(query.cd_predicate)
    }
    
    func test_predicate_unarchived() throws {
        let query = Query(isArchived: .unarchived, tag: nil, search: nil)
        print(query.cd_predicate.debugDescription)
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        XCTAssertEqual(predicate.debugDescription, "isArchived == 0")
    }
    
    func test_predicate_all_search() throws {
        let query = Query(isArchived: .all, tag: nil, search: "aString")
        print(query.cd_predicate.debugDescription)
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        XCTAssertEqual(predicate.debugDescription,
                       "title CONTAINS[cd] \"aString\" OR resolvedURL CONTAINS[cd] \"aString\" OR originalURL CONTAINS[cd] \"aString\"")
    }
    
    func test_predicate_unarchived_search() throws {
        let query = Query(isArchived: .unarchived, tag: nil, search: "aString")
        print(query.cd_predicate.debugDescription)
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        XCTAssertEqual(predicate.debugDescription,
                       "isArchived == 0 AND (title CONTAINS[cd] \"aString\" OR resolvedURL CONTAINS[cd] \"aString\" OR originalURL CONTAINS[cd] \"aString\")")
    }
    
    func test_predicate_all_search_tag() throws {
        let tag = try self.controller.createTag(name: "ATag").get()
        let _tag = tag.value.wrappedValue as! NSManagedObject
        let query = Query(isArchived: .all, tag: tag.value, search: "aString")
        print(query.cd_predicate.debugDescription)
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        print(_tag.objectID)
        XCTAssertEqual(predicate.predicateFormat,
                       "(title CONTAINS[cd] \"aString\" OR resolvedURL CONTAINS[cd] \"aString\" OR originalURL CONTAINS[cd] \"aString\") AND tags CONTAINS \(_tag)")
    }
    
    func test_predicate_unarchived_search_tag() throws {
        let tag = try self.controller.createTag(name: "ATag").get()
        let _tag = tag.value.wrappedValue as! NSManagedObject
        let query = Query(isArchived: .unarchived, tag: tag.value, search: "aString")
        print(query.cd_predicate.debugDescription)
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        print(_tag.objectID)
        XCTAssertEqual(predicate.predicateFormat,
                       "isArchived == 0 AND (title CONTAINS[cd] \"aString\" OR resolvedURL CONTAINS[cd] \"aString\" OR originalURL CONTAINS[cd] \"aString\") AND tags CONTAINS \(_tag)")
    }
    
}

