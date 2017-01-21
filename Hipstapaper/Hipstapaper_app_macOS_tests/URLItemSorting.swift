//
//  Hipstapaper_app_macOS_tests.swift
//  Hipstapaper_app_macOS_tests
//
//  Created by Jeffrey Bergier on 12/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

@testable import Hipstapaper
import RealmSwift
import XCTest

class URLItemSorting: XCTestCase {

    private let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: UUID().uuidString))

    override func setUp() {
        super.setUp()
        
        let extra1 = URLItemExtras(title: "A Page Title", imageData: .none)
        let url1 = URLItem()
        url1.urlString = "http://www.A.com"
        url1.archived = true
        url1.extras = extra1
        let extra2 = URLItemExtras(title: "a Page Title", imageData: .none)
        let url2 = URLItem()
        url2.urlString = "http://www.a.com"
        url2.archived = true
        url2.extras = extra2
        let extra3 = URLItemExtras(title: "B Page Title", imageData: .none)
        let url3 = URLItem()
        url3.urlString = "http://www.B.com"
        url3.archived = true
        url3.extras = extra3
        let extra4 = URLItemExtras(title: "b Page Title", imageData: .none)
        let url4 = URLItem()
        url4.urlString = "http://www.b.com"
        url4.archived = true
        url4.extras = extra4
        let extra5 = URLItemExtras(title: "Z Page Title", imageData: .none)
        let url5 = URLItem()
        url5.urlString = "http://www.Z.com"
        url5.archived = true
        url5.extras = extra5
        let extra6 = URLItemExtras(title: "z Page Title", imageData: .none)
        let url6 = URLItem()
        url6.urlString = "http://www.z.com"
        url6.archived = true
        url6.extras = extra6
        let extra7 = URLItemExtras(title: "0 Page Title", imageData: .none)
        let url7 = URLItem()
        url7.urlString = "http://www.0.com"
        url7.archived = false
        url7.extras = extra7
        let extra8 = URLItemExtras(title: "1 Page Title", imageData: .none)
        let url8 = URLItem()
        url8.urlString = "http://www.1.com"
        url8.archived = false
        url8.extras = extra8
        let extra9 = URLItemExtras(title: "01 Page Title", imageData: .none)
        let url9 = URLItem()
        url9.urlString = "http://www.01.com"
        url9.archived = false
        url9.extras = extra9
        let extra10 = URLItemExtras(title: "10 Page Title", imageData: .none)
        let url10 = URLItem()
        url10.urlString = "http://www.10.com"
        url10.archived = false
        url10.extras = extra10
        let extra11 = URLItemExtras(title: "20 Page Title", imageData: .none)
        let url11 = URLItem()
        url11.urlString = "http://www.20.com"
        url11.archived = false
        url11.extras = extra11
        let extra12 = URLItemExtras(title: "02 Page Title", imageData: .none)
        let url12 = URLItem()
        url12.urlString = "http://www.02.com"
        url12.archived = true
        url12.extras = extra12
        let extra13 = URLItemExtras(title: "2 Page Title", imageData: .none)
        let url13 = URLItem()
        url13.urlString = "http://www.2.com"
        url13.archived = true
        url13.extras = extra13
        
        self.realm.beginWrite()
        self.realm.add(url1)
        self.realm.add(url2)
        self.realm.add(url3)
        self.realm.add(url4)
        self.realm.add(url5)
        self.realm.add(url6)
        self.realm.add(url7)
        self.realm.add(url8)
        self.realm.add(url9)
        self.realm.add(url10)
        self.realm.add(url11)
        self.realm.add(url12)
        self.realm.add(url13)
        try! self.realm.commitWrite()
    }
    
    func testItemCount() {
        let items = self.realm.objects(URLItem.self)
        XCTAssert(items.count == 13)
    }
    
    func testURLStringSortAFirst() {
        let sort = URLItem.SortOrder.urlAOnTop
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly =
            sortedResults[0].urlString == "http://www.0.com" &&
                sortedResults[1].urlString == "http://www.01.com" &&
                sortedResults[2].urlString == "http://www.02.com" &&
                sortedResults[3].urlString == "http://www.1.com" &&
                sortedResults[4].urlString == "http://www.10.com" &&
                sortedResults[5].urlString == "http://www.2.com" &&
                sortedResults[6].urlString == "http://www.20.com" &&
                sortedResults[7].urlString == "http://www.a.com" &&
                sortedResults[8].urlString == "http://www.A.com" &&
                sortedResults[9].urlString == "http://www.b.com" &&
                sortedResults[10].urlString == "http://www.B.com" &&
                sortedResults[11].urlString == "http://www.z.com" &&
                sortedResults[12].urlString == "http://www.Z.com"
        
        XCTAssert(sortedCorrectly)
    }
    
    func testURLStringSortZFirst() {
        let sort = URLItem.SortOrder.urlZOnTop
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly =
            sortedResults[12].urlString == "http://www.0.com" &&
                sortedResults[11].urlString == "http://www.01.com" &&
                sortedResults[10].urlString == "http://www.02.com" &&
                sortedResults[9].urlString == "http://www.1.com" &&
                sortedResults[8].urlString == "http://www.10.com" &&
                sortedResults[7].urlString == "http://www.2.com" &&
                sortedResults[6].urlString == "http://www.20.com" &&
                sortedResults[5].urlString == "http://www.a.com" &&
                sortedResults[4].urlString == "http://www.A.com" &&
                sortedResults[3].urlString == "http://www.b.com" &&
                sortedResults[2].urlString == "http://www.B.com" &&
                sortedResults[1].urlString == "http://www.z.com" &&
                sortedResults[0].urlString == "http://www.Z.com"
        
        XCTAssert(sortedCorrectly)
    }
    
    func testArchivedFirst() {
        let sort = URLItem.SortOrder.archivedOnTop
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly =
            sortedResults[0].archived == true &&
                sortedResults[1].archived == true &&
                sortedResults[2].archived == true &&
                sortedResults[3].archived == true &&
                sortedResults[4].archived == true &&
                sortedResults[5].archived == true &&
                sortedResults[6].archived == true &&
                sortedResults[7].archived == true &&
                sortedResults[8].archived == false &&
                sortedResults[9].archived == false &&
                sortedResults[10].archived == false &&
                sortedResults[11].archived == false &&
                sortedResults[12].archived == false
        
        XCTAssert(sortedCorrectly)
    }
    
    func testUnarchivedFirst() {
        let sort = URLItem.SortOrder.unarchivedOnTop
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly =
            sortedResults[12].archived == true &&
                sortedResults[11].archived == true &&
                sortedResults[10].archived == true &&
                sortedResults[9].archived == true &&
                sortedResults[8].archived == true &&
                sortedResults[7].archived == true &&
                sortedResults[6].archived == true &&
                sortedResults[5].archived == true &&
                sortedResults[4].archived == false &&
                sortedResults[3].archived == false &&
                sortedResults[2].archived == false &&
                sortedResults[1].archived == false &&
                sortedResults[0].archived == false
        
        XCTAssert(sortedCorrectly)
    }
    
    func testCreationDateNewestFirst() {
        let sort = URLItem.SortOrder.recentlyAddedOnTop
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly = sortedResults[0].creationDate > sortedResults[12].creationDate
        
        XCTAssert(sortedCorrectly)
    }
    
    func testCreationDateOldestFirst() {
        let sort = URLItem.SortOrder.recentlyAddedOnBottom
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly = sortedResults[0].creationDate < sortedResults[12].creationDate
        
        XCTAssert(sortedCorrectly)
    }
    
    func testModificationDateNewestFirst() {
        let sort = URLItem.SortOrder.recentlyModifiedOnTop
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly = sortedResults[0].modificationDate > sortedResults[12].modificationDate
        
        XCTAssert(sortedCorrectly)
    }
    
    func testModificationDateOldestFirst() {
        let sort = URLItem.SortOrder.recentlyModifiedOnBottom
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly = sortedResults[0].modificationDate < sortedResults[12].modificationDate
        
        XCTAssert(sortedCorrectly)
    }
    /*
    func testTagCountMostFirst() {
        let sort = URLItem.SortOrder.tagCount(mostFirst: true)
        let items = sort.sort(results: self.realm.objects(URLItem.self))
        XCTAssert(true)
    }
*/
    
    func testPageTitleSortAFirst() {
        let sort = URLItem.SortOrder.pageTitleAOnTop
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly =
            sortedResults[0].extras!.pageTitle == "0 Page Title" &&
                sortedResults[1].extras!.pageTitle == "01 Page Title" &&
                sortedResults[2].extras!.pageTitle == "02 Page Title" &&
                sortedResults[3].extras!.pageTitle == "1 Page Title" &&
                sortedResults[4].extras!.pageTitle == "10 Page Title" &&
                sortedResults[5].extras!.pageTitle == "2 Page Title" &&
                sortedResults[6].extras!.pageTitle == "20 Page Title" &&
                sortedResults[7].extras!.pageTitle == "a Page Title" &&
                sortedResults[8].extras!.pageTitle == "A Page Title" &&
                sortedResults[9].extras!.pageTitle == "b Page Title" &&
                sortedResults[10].extras!.pageTitle == "B Page Title" &&
                sortedResults[11].extras!.pageTitle == "z Page Title" &&
                sortedResults[12].extras!.pageTitle == "Z Page Title"
        
        XCTAssert(sortedCorrectly)
    }
    
    func testPageTitleSortZFirst() {
        let sort = URLItem.SortOrder.pageTitleZOnTop
        let unsortedResults = self.realm.objects(URLItem.self)
        let sortedResults = sort.sort(results: unsortedResults)
        
        XCTAssert(unsortedResults.count == sortedResults.count)
        
        let sortedCorrectly =
            sortedResults[12].extras!.pageTitle == "0 Page Title" &&
                sortedResults[11].extras!.pageTitle == "01 Page Title" &&
                sortedResults[10].extras!.pageTitle == "02 Page Title" &&
                sortedResults[9].extras!.pageTitle == "1 Page Title" &&
                sortedResults[8].extras!.pageTitle == "10 Page Title" &&
                sortedResults[7].extras!.pageTitle == "2 Page Title" &&
                sortedResults[6].extras!.pageTitle == "20 Page Title" &&
                sortedResults[5].extras!.pageTitle == "a Page Title" &&
                sortedResults[4].extras!.pageTitle == "A Page Title" &&
                sortedResults[3].extras!.pageTitle == "b Page Title" &&
                sortedResults[2].extras!.pageTitle == "B Page Title" &&
                sortedResults[1].extras!.pageTitle == "z Page Title" &&
                sortedResults[0].extras!.pageTitle == "Z Page Title"
        
        XCTAssert(sortedCorrectly)
    }
}
