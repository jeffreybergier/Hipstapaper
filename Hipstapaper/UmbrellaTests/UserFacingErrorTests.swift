//
//  Created by Jeffrey Bergier on 2021/02/22.
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
import SwiftUI
import Umbrella

enum ImplicitError: UserFacingError {
    var message: LocalizedStringKey { "My Explicit Message" }
    case all
}

enum ExplicitError: UserFacingError {
    static var errorDomain: String = "MyExplicitErrorDomain"
    var message: LocalizedStringKey { "My Explicit Message" }
    var title: LocalizedStringKey { "MyExplicitTitle" }
    var dismissTitle: LocalizedStringKey { "MyExplicitDismiss" }
    var errorCode: Int { 123_456_789 }
    var errorUserInfo: [String : Any] { ["A": 10] }
    var options: [RecoveryOption] { [.init(title: "MyExplicitOption1", isDestructive: true, perform: {})] }
    case all
}

class UserFacingErrorTests: XCTestCase {
    
    func test_localizations() {
        XCTAssertEqual(ImplicitError.all.title, "Noun.Error")
        XCTAssertEqual(ImplicitError.all.dismissTitle, "Verb.Dismiss")
        XCTAssertEqual(ExplicitError.all.title, "MyExplicitTitle")
        XCTAssertEqual(ExplicitError.all.dismissTitle, "MyExplicitDismiss")
    }
    
    func test_domain() {
        XCTAssertEqual(ImplicitError.errorDomain, "com.saturdayapps.UmbrellaTests.ImplicitError")
        XCTAssertEqual(ExplicitError.errorDomain, "MyExplicitErrorDomain")
    }
    
    func test_code() {
        XCTAssertEqual(ImplicitError.all.errorCode, 0)
        XCTAssertEqual(ExplicitError.all.errorCode, 123_456_789)
    }
    
    func test_userInfo() {
        XCTAssertTrue(ImplicitError.all.errorUserInfo.isEmpty)
        XCTAssertFalse(ExplicitError.all.errorUserInfo.isEmpty)
        let a = ExplicitError.all.errorUserInfo["A"] as! Int
        XCTAssertNotNil(ExplicitError.all.errorUserInfo["A"])
        XCTAssertEqual(a, 10)
    }
    
    func test_options() {
        XCTAssertTrue(ImplicitError.all.options.isEmpty)
        XCTAssertFalse(ExplicitError.all.options.isEmpty)
        XCTAssertEqual(ExplicitError.all.options.first?.isDestructive, true)
        XCTAssertEqual(ExplicitError.all.options.first?.title, "MyExplicitOption1")
    }
    
}
