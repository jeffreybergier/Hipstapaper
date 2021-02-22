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
    /// Automatic implementation uses Swift.Mirror and other fragile hackery.
    public static var errorDomain: String {
        let mirror = Mirror(reflecting: self)
        let typeString = mirror.typeDescription
        let bundle = mirror.typeBundle.bundleIdentifier ?? "unknown.bundleid"
        let domain = bundle + "." + typeString
        return domain
    }
}

extension Mirror {
    
    private var frameworkName: String {
        return _full_typeDescription.components(separatedBy: ".").first ?? "unknownbundle"
    }
    
    private var _full_typeDescription: String {
        let typeString = _typeName(self.subjectType)
        let _nameComponents = typeString.components(separatedBy: ".")
        let nameComponents = _nameComponents.dropLast()
        return nameComponents.joined(separator: ".")
    }
    
    fileprivate var typeDescription: String {
        let components = _full_typeDescription.components(separatedBy: ".")
        let trimmed = Array(components.dropFirst())
        let recombined = trimmed.joined(separator: ".")
        return recombined
    }
    
    fileprivate var typeBundle: Bundle {
        let bundles = (Bundle.allBundles + Bundle.allFrameworks)
                      .filter { !($0.bundleIdentifier ?? "com.apple").starts(with: "com.apple") }
        let myFramwork = self.frameworkName.lowercased()
        let _bundleMatch = bundles.filter { ($0.bundleIdentifier ?? "").lowercased().contains(myFramwork) }
        guard let bundleMatch = _bundleMatch.first else {
            log.error("Reflection Error")
            return Bundle.main
        }
        return bundleMatch
    }
}
