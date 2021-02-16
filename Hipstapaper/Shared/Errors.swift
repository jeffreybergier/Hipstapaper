//
//  Created by Jeffrey Bergier on 2021/01/19.
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

import Stylize

enum Error: LocalizedError {
    case shareExtensionAdd
    case cloudAccount
    
    var errorDescription: String? {
        switch self {
        case .cloudAccount:
            // TODO: Fix this
            return "You're not logged into iCloud. Sign into an iCloud account to sync."
        case .shareExtensionAdd:
            return "There was an error when adding a website saved by another application."
        }
    }
}

protocol ErrorQ: class {
    func append(_ error: LocalizedError)
    @discardableResult
    func append<T, E: LocalizedError>(_ result: Result<T, E>) -> Result<T, E>
}

// TODO: Move errorQ to Umbrella
extension STZ.ERR.ViewModel: ErrorQ {}
