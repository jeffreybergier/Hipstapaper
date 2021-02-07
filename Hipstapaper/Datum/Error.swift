//
//  Created by Jeffrey Bergier on 2020/11/24.
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

import Foundation

internal let ISTESTING: Bool = NSClassFromString("XCTestCase") != nil

// TODO: Conform to NSError Protocols
public enum Error: Swift.Error {
    case critical
    case unknown
}

// TODO: Add cases here
extension Error: LocalizedError {
    public var errorDescription: String? {
        return "LOCALIZE THIS ERROR"
    }
}

internal struct CocoaError: LocalizedError {
    var error: NSError
    var errorDescription: String? { error.localizedDescription }
    var failureReason: String? { error.localizedFailureReason }
    var recoverySuggestion: String? { error.localizedRecoverySuggestion }
}
