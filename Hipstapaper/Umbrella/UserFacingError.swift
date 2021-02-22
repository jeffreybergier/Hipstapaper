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

public protocol UserFacingError: CustomNSError {
    /// Default implementation is "Noun.Error"
    var title: LocalizedStringKey { get }
    var message: LocalizedStringKey { get }
    /// Default implementation is "Verb.Dismiss"
    var dismissTitle: LocalizedStringKey { get }
    /// Default implementation is empty.
    /// If options are present the Alert/UI for the error should show the options
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
    
    public var options: [RecoveryOption] {
        return []
    }
}

extension UserFacingError {
    /// Default implementation `com.your.bundle.id.ParentType.ErrorType`
    /// Override if you want something custom or automatic implementation no longer works
    /// Automatic implementation uses fragile hackery.
    public static var errorDomain: String {
        let typeString = __typeName(self)
        let bundle = Bundle.for(type: self) ?? .main
        let id = bundle.bundleIdentifier ?? "unknown.bundleid"
        let domain = id + "." + typeString
        return domain
    }
}
