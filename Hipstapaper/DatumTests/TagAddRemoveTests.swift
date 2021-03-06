//
//  Created by Jeffrey Bergier on 2020/12/19.
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
        let idx1_0 = status1.startIndex
        let idx1_1 = status1.index(after: idx1_0)
        XCTAssertEqual(status1.count, 2)
        XCTAssertEqual(status1[idx1_0].0, tag1)
        XCTAssertEqual(status1[idx1_1].0, tag2)
        XCTAssertEqual(status1[idx1_0].1, .on)
        XCTAssertEqual(status1[idx1_1].1, .off)
        
        let status2 = try self.controller.tagStatus(for: [site2]).get()
        let idx2_0 = status2.startIndex
        let idx2_1 = status2.index(after: idx2_0)
        XCTAssertEqual(status2.count, 2)
        XCTAssertEqual(status2[idx2_0].0, tag1)
        XCTAssertEqual(status2[idx2_1].0, tag2)
        XCTAssertEqual(status2[idx2_0].1, .off)
        XCTAssertEqual(status2[idx2_1].1, .on)
        
        let status3 = try self.controller.tagStatus(for: [site1, site2]).get()
        let idx3_0 = status3.startIndex
        let idx3_1 = status3.index(after: idx3_0)
        XCTAssertEqual(status3.count, 2)
        XCTAssertEqual(status3[idx3_0].0, tag1)
        XCTAssertEqual(status3[idx3_1].0, tag2)
        XCTAssertEqual(status3[idx3_0].1, .mixed)
        XCTAssertEqual(status3[idx3_1].1, .mixed)
        
        let status4 = try self.controller.tagStatus(for: []).get()
        let idx4_0 = status4.startIndex
        let idx4_1 = status4.index(after: idx4_0)
        XCTAssertEqual(status4.count, 2)
        XCTAssertEqual(status4[idx4_0].0, tag1)
        XCTAssertEqual(status4[idx4_1].0, tag2)
        XCTAssertEqual(status4[idx4_0].1, .off)
        XCTAssertEqual(status4[idx4_1].1, .off)
    }
    
}
