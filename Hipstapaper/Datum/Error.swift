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

import SwiftUI
import Umbrella
import Localize

/// Programming errors like not being able to load MOM from bundle
/// and updating values from different Context cause fatalError
/// rather than throwing an error.
public enum Error: UserFacingError {
    /// When an error is returned from `NSPersistentContainter`.
    case initialize(NSError)
    /// When asked to update values on the wrong type.
    case write(NSError)
    /// When NSManagedContext return an error while `performFetch()`
    case read(NSError)
    
    var errorValue: NSError {
        switch self {
        case .initialize(let error), .read(let error), .write(let error):
            return error
        }
    }
    
    public static var errorDomain: String = "com.saturdayapps.Hipstapaper.Datum"
    
    public var errorCode: Int {
        switch self {
        case .initialize:
            return 1001
        case .read:
            return 1002
        case .write:
            return 1003
        }
    }
    
    public var title: LocalizedStringKey {
        return Noun.errorDatabase.rawValue
    }
    
    public var message: LocalizedStringKey {
        return .init(self.errorValue.localizedDescription)
    }
}
