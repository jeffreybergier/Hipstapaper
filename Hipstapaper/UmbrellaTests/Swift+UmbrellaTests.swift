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
@testable import Umbrella

class SwiftUmbrellaTests: XCTestCase {

    func test_result() {
        let randomInt = Int.random(in: 0..<Int.max)
        let r1: Result<Int, GenericError> = .success(randomInt)
        XCTAssertEqual(r1.value, randomInt)
        XCTAssertNil(r1.error)
        let error = GenericError(errorCode: randomInt, message: "")
        let r2: Result<Int, GenericError> = .failure(error)
        XCTAssertNil(r2.value)
        XCTAssertEqual(r2.error!.errorCode, randomInt)
    }
    
    func test_typeName() {
        XCTAssertEqual(_typeName(String.self), "Swift.String")
        XCTAssertEqual(__typeName(String.self), "String")
        XCTAssertEqual(_typeName(GenericWebKitNavigationDelegate.Error.self),
                       "Umbrella.GenericWebKitNavigationDelegate.Error")
        XCTAssertEqual(__typeName(GenericWebKitNavigationDelegate.Error.self),
                       "GenericWebKitNavigationDelegate.Error")
        XCTAssertEqual(_typeName(ImplicitError.self), "UmbrellaTests.ImplicitError")
        XCTAssertEqual(__typeName(ImplicitError.self), "ImplicitError")
    }
    
    func test_typeName_framework() {
        XCTAssertEqual(__typeName_framework(String.self), "Swift")
        XCTAssertEqual(__typeName_framework(GenericWebKitNavigationDelegate.Error.self), "Umbrella")
        XCTAssertEqual(__typeName_framework(ImplicitError.self), "UmbrellaTests")
    }
    
    func test_bundle_init() {
        // Apple frameworks are expected to return nil
        XCTAssertNil(Bundle.for(type: String.self))
        let bundle1 = Bundle.for(type: GenericWebKitNavigationDelegate.Error.self)
        XCTAssertNotNil(bundle1)
        XCTAssertEqual(bundle1?.bundleIdentifier, "com.saturdayapps.Umbrella")
        let bundle2 = Bundle.for(type: ImplicitError.self)
        XCTAssertNotNil(bundle2)
        XCTAssertEqual(bundle2?.bundleIdentifier, "com.saturdayapps.UmbrellaTests")
    }
    
}
