//
//  Created by Jeffrey Bergier on 2021/02/19.
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

public struct GenericError: UserFacingError {
    public var errorCode: Int
    public var errorUserInfo: [String : Any]
    public var message: LocalizedStringKey
    public var options: [RecoveryOption]
    
    public init(errorCode: Int,
                errorUserInfo: [String : Any] = [:],
                message: LocalizedStringKey,
                options: [RecoveryOption] = [])
    {
        self.errorCode = errorCode
        self.errorUserInfo = errorUserInfo
        self.message = message
        self.options = options
    }
    
    public init(_ error: NSError, options: [RecoveryOption] = []) {
        self.errorCode = error.code
        self.errorUserInfo = error.userInfo
        // TODO: Add support for localizedFailureReason
        self.message = .init(error.localizedDescription)
        self.options = options
    }
}
