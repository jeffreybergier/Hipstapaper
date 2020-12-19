//
//  Created by Jeffrey Bergier on 2020/12/19.
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

class TagAddRemoveTests: ParentTestCase {
    
    func test_add_tag() throws {
        let site = try self.controller.createWebsite(.init(title: "ASite")).get()
        let tag = try self.controller.createTag(name: "ATag").get()
        let wSite = site.value.wrappedValue as! CD_Website
        let wTag = tag.value.wrappedValue as! CD_Tag
        XCTAssertEqual(wSite.cd_tags.count, 0)
        XCTAssertEqual(wTag.cd_websites.count, 0)
        try self.controller.add(tag: tag, to: [site]).get()
        XCTAssertEqual(wSite.cd_tags.count, 1)
        XCTAssertEqual(wTag.cd_websites.count, 1)
        try self.controller.add(tag: tag, to: [site]).get()
        XCTAssertEqual(wSite.cd_tags.count, 1)
        XCTAssertEqual(wTag.cd_websites.count, 1)
    }
    
    func test_remove_tag() throws {
        let site = try self.controller.createWebsite(.init(title: "ASite")).get()
        let tag = try self.controller.createTag(name: "ATag").get()
        let wSite = site.value.wrappedValue as! CD_Website
        let wTag = tag.value.wrappedValue as! CD_Tag
        XCTAssertEqual(wSite.cd_tags.count, 0)
        XCTAssertEqual(wTag.cd_websites.count, 0)
        try self.controller.add(tag: tag, to: [site]).get()
        XCTAssertEqual(wSite.cd_tags.count, 1)
        XCTAssertEqual(wTag.cd_websites.count, 1)
        try self.controller.remove(tag: tag, from: [site]).get()
        XCTAssertEqual(wSite.cd_tags.count, 0)
        XCTAssertEqual(wTag.cd_websites.count, 0)
    }
    
}
