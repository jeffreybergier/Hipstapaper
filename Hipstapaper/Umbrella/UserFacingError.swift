//
//  Created by Jeffrey Bergier on 2021/02/17.
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

import SwiftUI

public typealias UFError = UserFacingError
public typealias RUFError = RecoverableUserFacingError

public protocol UserFacingError: CustomNSError {
    /// Default implementation is "Noun.Error"
    var title: LocalizedStringKey { get }
    var message: LocalizedStringKey { get }
    /// Default implementation is "Verb.Dismiss"
    var dismissTitle: LocalizedStringKey { get }
}

public protocol RecoverableUserFacingError: UserFacingError {
    var options: [RecoveryOption] { get }
}

public struct RecoveryOption {
    public var title: LocalizedStringKey
    public var isDestructive: Bool
    public var perform: () -> Void
    public init(title: LocalizedStringKey,
                isDestructive: Bool = false,
                perform: @escaping () -> Void)
    {
        self.title = title
        self.isDestructive = isDestructive
        self.perform = perform
    }
}

extension UserFacingError {
    /// Default implementation. Override to customize
    public var title: LocalizedStringKey {
        return "Noun.Error"
    }
    /// Default implementation. Override to customize
    public var dismissTitle: LocalizedStringKey {
        return "Verb.Dismiss"
    }
}

extension UserFacingError {
    /// Default implementation `com.your.bundle.id.ParentType.ErrorType`
    /// Override if you want something custom or automatic implementation no longer works
    /// Automatic implementation uses fragile hackery.
    public static var errorDomain: String {
        let typeString = self.typeName
        let bundle = self.typeBundle.bundleIdentifier ?? "unknown.bundleid"
        let domain = bundle + "." + typeString
        return domain
    }
    
    private static var _typeName_framework: String {
        return _typeName(self)
            .components(separatedBy: ".")
            .first ?? "unknownbundle"
    }
    
    private static var typeName: String {
        return _typeName(self)
            .components(separatedBy: ".")
            .dropFirst()
            .joined(separator: ".")
    }
    
    private static var typeBundle: Bundle {
        let check1: (Bundle) -> Bool = {
            let id = $0.bundleIdentifier ?? "com.apple"
            return id.starts(with: "com.apple") == false
        }
        let check2: (Bundle) -> Bool = {
            let id = $0.bundleIdentifier ?? ""
            return id.lowercased().contains(_typeName_framework.lowercased())
        }
        let allBundles = Bundle.allBundles + Bundle.allFrameworks
        return allBundles.first(where: { check1($0) && check2($0) }) ?? .main
    }
}
