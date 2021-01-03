//
//  Created by Jeffrey Bergier on 2020/12/30.
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

import Foundation

protocol WindowManagerProtocol {
    var features: WindowManager.Features { get }
    func show(_: Set<URL>, error: @escaping (WindowManager.Error) -> Void)
}

extension WindowManager {
    enum Error: Swift.Error {
        /// Occurs when the device does not support bulk opening multiple windwos
        case bulkActivation
        /// Occurs when the UIScene API returns an error on activation
        case activation(Swift.Error)
        /// Occurs when the device does not support multitple windows.
        /// Please display your window modally in this case
        case unsupported
    }
    
    struct Features: OptionSet {
        let rawValue: Int
        static let multipleWindows = Features(rawValue: 1 << 0)
        static let bulkActivation  = Features(rawValue: 1 << 1)
    }
}
