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
        let query = Query(isArchived: .all, tag: nil, search: "")
        XCTAssertNil(query.cd_predicate)
    }
    
    func test_predicate_unarchived() throws {
        let query = Query(isArchived: .unarchived, tag: nil, search: "")
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        XCTAssertEqual(predicate.debugDescription, "cd_isArchived == 0")
    }
    
    func test_predicate_all_search() throws {
        let query = Query(isArchived: .all, tag: nil, search: "aString")
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        XCTAssertEqual(predicate.debugDescription,
                       "cd_title CONTAINS[cd] \"aString\" OR cd_resolvedURL CONTAINS[cd] \"aString\" OR cd_originalURL CONTAINS[cd] \"aString\"")
    }
    
    func test_predicate_unarchived_search() throws {
        let query = Query(isArchived: .unarchived, tag: nil, search: "aString")
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        XCTAssertEqual(predicate.debugDescription,
                       "cd_isArchived == 0 AND (cd_title CONTAINS[cd] \"aString\" OR cd_resolvedURL CONTAINS[cd] \"aString\" OR cd_originalURL CONTAINS[cd] \"aString\")")
    }
    
    func test_predicate_all_search_tag() throws {
        let tag = try self.controller.createTag(name: "ATag").get()
        let _tag = tag.value.wrappedValue as! NSManagedObject
        let query = Query(isArchived: .all, tag: tag, search: "aString")
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        XCTAssertEqual(predicate.predicateFormat,
                       "(cd_title CONTAINS[cd] \"aString\" OR cd_resolvedURL CONTAINS[cd] \"aString\" OR cd_originalURL CONTAINS[cd] \"aString\") AND cd_tags CONTAINS \(_tag)")
    }
    
    func test_predicate_unarchived_search_tag() throws {
        let tag = try self.controller.createTag(name: "ATag").get()
        let _tag = tag.value.wrappedValue as! NSManagedObject
        let query = Query(isArchived: .unarchived, tag: tag, search: "aString")
        guard let predicate = query.cd_predicate else { XCTFail(); return }
        XCTAssertEqual(predicate.predicateFormat,
                       "cd_isArchived == 0 AND (cd_title CONTAINS[cd] \"aString\" OR cd_resolvedURL CONTAINS[cd] \"aString\" OR cd_originalURL CONTAINS[cd] \"aString\") AND cd_tags CONTAINS \(_tag)")
    }
    
}

