//
//  Created by Jeffrey Bergier on 2020/11/28.
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

