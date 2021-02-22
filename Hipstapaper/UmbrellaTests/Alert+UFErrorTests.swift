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

class AlertUFErrorTests: XCTestCase {
    
    func test_noOptions() {
        let alert = Alert(ImplicitError.all)
        var dumpS = String()
        dump(alert, to: &dumpS)
        XCTAssertTrue(dumpS.contains("style: SwiftUI.Alert.Button.Style.cancel"))
        XCTAssertTrue(dumpS.contains("My Explicit Message"))
        XCTAssertTrue(dumpS.contains("Noun.Error"))
        XCTAssertTrue(dumpS.contains("Verb.Dismiss"))
        XCTAssertFalse(dumpS.contains("MyExplicitDismiss"))
        XCTAssertFalse(dumpS.contains("MyExplicitTitle"))
        XCTAssertFalse(dumpS.contains("SwiftUI.Alert.Button.Style.destructive"))
        XCTAssertFalse(dumpS.contains("MyExplicitOption1"))
    }
    
    func test_options() {
        let alert = Alert(ExplicitError.all)
        var dumpS = String()
        dump(alert, to: &dumpS)
        XCTAssertTrue(dumpS.contains("MyExplicitDismiss"))
        XCTAssertTrue(dumpS.contains("style: SwiftUI.Alert.Button.Style.cancel"))
        XCTAssertTrue(dumpS.contains("My Explicit Message"))
        XCTAssertTrue(dumpS.contains("MyExplicitTitle"))
        XCTAssertTrue(dumpS.contains("SwiftUI.Alert.Button.Style.destructive"))
        XCTAssertTrue(dumpS.contains("MyExplicitOption1"))
        XCTAssertFalse(dumpS.contains("Noun.Error"))
        XCTAssertFalse(dumpS.contains("Verb.Dismiss"))
    }
}
