//
//  Created by Jeffrey Bergier on 2021/02/17.
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

extension Alert {
    public init(_ error: UFError, dismissAction: @escaping () -> Void = {}) {
        if !error.options.isEmpty {
            self.init(RUFError: error, dismissAction: dismissAction)
        } else {
            self.init(UFError: error, dismissAction: dismissAction)
        }
    }
    
    private init(UFError error: UFError, dismissAction: @escaping () -> Void) {
        self.init(title: Text(error.title),
                  message: Text(error.message),
                  dismissButton: .cancel(Text(error.dismissTitle),
                                         action: dismissAction))
    }
    
    private init(RUFError error: UFError, dismissAction: @escaping () -> Void) {
        precondition(error.options.count == 1, "Currently only 1 recovery option is supported")
        self.init(title: Text(error.title),
                  message: Text(error.message),
                  primaryButton: .init(error.options[0]),
                  secondaryButton: .cancel(Text(error.dismissTitle),
                                           action: dismissAction))
    }
}

extension Alert.Button {
    public init(_ option: RecoveryOption) {
        if option.isDestructive {
            self = .destructive(Text(option.title), action: option.perform)
        } else {
            self = .default(Text(option.title), action: option.perform)
        }
    }
}
