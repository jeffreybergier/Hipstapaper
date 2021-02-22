//
//  Created by Jeffrey Bergier on 2020/12/02.
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

extension Result {
    public var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    public var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

/// Returns the same output of `_typeName` but missing the framework name at the beginning
public func __typeName(_ input: Any.Type) -> String {
    return _typeName(input)
        .components(separatedBy: ".")
        .dropFirst()
        .joined(separator: ".")
}

// Internal for testing only
internal func __typeName_framework(_ input: Any.Type) -> String {
    return _typeName(input)
        .components(separatedBy: ".")
        .first ?? "unknownbundle"
}

extension Bundle {
    /// Uses fragile (and slow) method to find Bundle for a non-objective-c type
    /// If you need the bundle for an Objective-C type, please use the correct initalizer
    public static func `for`(type input: Any.Type) -> Bundle? {
        let check1: (Bundle) -> Bool = {
            !($0.bundleIdentifier ?? "com.apple").hasPrefix("com.apple")
        }
        let check2: (Bundle) -> Bool = {
            ($0.bundleIdentifier ?? "")
                .lowercased()
                .hasSuffix(
                    __typeName_framework(input).lowercased()
                )
        }
        let allBundles = Bundle.allBundles + Bundle.allFrameworks
        return allBundles.first(where: { check1($0) && check2($0) })
    }
}
