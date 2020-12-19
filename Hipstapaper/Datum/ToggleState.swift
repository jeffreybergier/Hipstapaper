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

public enum ToggleState {
    case off
    case mixed
    case on
    
    public init(_ input: [Bool]) {
        let offTest = input.filter { !$0 }
        if offTest.count == input.count {
            self = .off
            return
        }
        let onTest = input.filter { $0 }
        if onTest.count == input.count {
            self = .on
            return
        }
        self = .mixed
        return
    }
}

#if canImport(AppKit)
import AppKit
extension ToggleState {
    var nativeValue: NSControl.StateValue {
        switch self {
        case .mixed:
            return .mixed
        case .off:
            return .off
        case .on:
            return .on
        }
    }
}
#else
import UIKit
extension ToggleState {
    var nativeValue: Bool {
        switch self {
        case .off:
            return false
        case .on, .mixed:
            return true
        }
    }
}
#endif
