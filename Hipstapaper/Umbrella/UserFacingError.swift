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
    var title: LocalizedStringKey { get }
    var description: LocalizedStringKey { get }
}

public protocol RecoverableError: UserFacingError {
    var options: [RecoveryOption<Self>] { get }
}

public struct RecoveryOption<T> {
    public var title: LocalizedStringKey
    public var perform: (T) -> Void
    public init(title: LocalizedStringKey, perform: @escaping (T) -> Void) {
        self.title = title
        self.perform = perform
    }
}
