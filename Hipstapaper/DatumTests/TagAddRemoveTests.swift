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
    
    func test_tagStatus() throws {
        let site1 = try self.controller.createWebsite(.init(title: "ASite")).get()
        let site2 = try self.controller.createWebsite(.init(title: "BSite")).get()
        let tag1 = try self.controller.createTag(name: "ATag").get()
        let tag2 = try self.controller.createTag(name: "BTag").get()
        try self.controller.add(tag: tag1, to: [site1]).get()
        try self.controller.add(tag: tag2, to: [site2]).get()
        let status1 = try self.controller.tagStatus(for: [site1]).get()
        XCTAssertEqual(status1.count, 2)
        XCTAssertEqual(status1[0].0, tag1)
        XCTAssertEqual(status1[1].0, tag2)
        XCTAssertEqual(status1[0].1, .on)
        XCTAssertEqual(status1[1].1, .off)
        
        let status2 = try self.controller.tagStatus(for: [site2]).get()
        XCTAssertEqual(status2.count, 2)
        XCTAssertEqual(status2[0].0, tag1)
        XCTAssertEqual(status2[1].0, tag2)
        XCTAssertEqual(status2[0].1, .off)
        XCTAssertEqual(status2[1].1, .on)
        
        let status3 = try self.controller.tagStatus(for: [site1, site2]).get()
        XCTAssertEqual(status3.count, 2)
        XCTAssertEqual(status3[0].0, tag1)
        XCTAssertEqual(status3[1].0, tag2)
        XCTAssertEqual(status3[0].1, .mixed)
        XCTAssertEqual(status3[1].1, .mixed)
        
        let status4 = try self.controller.tagStatus(for: []).get()
        XCTAssertEqual(status4.count, 2)
        XCTAssertEqual(status4[0].0, tag1)
        XCTAssertEqual(status4[1].0, tag2)
        XCTAssertEqual(status4[0].1, .off)
        XCTAssertEqual(status4[1].1, .off)
    }
    
}
