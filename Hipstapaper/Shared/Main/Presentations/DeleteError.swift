//
//  Created by Jeffrey Bergier on 2021/02/06.
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
import Stylize
import Datum

enum DeleteError: RecoverableUserFacingError {
    
    typealias OnConfirmation = () -> Void
    
    case website(OnConfirmation)
    case tag(OnConfirmation)
    
    var title: LocalizedStringKey {
        switch self {
        case .tag:
            return "Phrase.Delete Tag(s)?"
        case .website:
            return "Phrase.Delete Website(s)?"
        }
    }
    var message: LocalizedStringKey {
        "Phrase.Deleted item(s) will be deleted from all devices. This cannot be undone."
    }
    var options: [RecoveryOption] {
        switch self {
        case .tag(let onConfirm), .website(let onConfirm):
            return [.init(title: "Verb.Delete", isDestructive: true, perform: onConfirm)]
        }
    }
}

