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
import Umbrella

class GenericErrorTests: XCTestCase {
    
    lazy var realError: NSError = {
        do {
            try FileManager.default.contentsOfDirectory(atPath: "xxx://this-is-not-a-path")
            fatalError()
        } catch {
            return error as NSError
        }
    }()
    
    func test_initWithNSError() {
        let error = GenericError(self.realError)
        XCTAssertEqual(error.errorCode, 260)
        XCTAssertEqual(error.message,
                       "The folder “this-is-not-a-path” doesn’t exist.")
        XCTAssertEqual(Set(error.errorUserInfo.keys),
                       Set(["NSUnderlyingError", "NSFilePath", "NSUserStringVariant"]))
        
        // Sanity tests
        XCTAssertEqual(self.realError.localizedDescription, "The folder “this-is-not-a-path” doesn’t exist.")
        XCTAssertEqual(self.realError.localizedFailureReason, "The folder doesn’t exist.")
        XCTAssertNil(self.realError.localizedRecoverySuggestion)
    }
}
