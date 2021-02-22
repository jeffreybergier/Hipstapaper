//
//  Created by Jeffrey Bergier on 2020/12/06.
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

public enum Error: UserFacingError {
    case take(Swift.Error)
    case convertImage
    case size(Int)
    case userCancelled
    case sx_save
    case sx_process
}

extension Error: LocalizedError {
    public var message: LocalizedStringKey {
        switch self {
        case .take:
            return Phrase.errorScreenshot.rawValue
        case .convertImage:
            return Phrase.errorConvertImage.rawValue
        case .size:
            return Phrase.errorImageSize.rawValue
        case .userCancelled:
            return Phrase.errorUserCancel.rawValue
        case .sx_process:
            return Phrase.errorProcessURL.rawValue
        case .sx_save:
            return Phrase.errorSaveWebsite.rawValue
        }
    }
}
