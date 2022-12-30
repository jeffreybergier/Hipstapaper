//
//  Created by Jeffrey Bergier on 2022/11/20.
//
//  Copyright © 2022 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import Umbrella

public struct ErrorPresenter: ViewModifier {
    
    private let bundle: any EnvironmentBundleProtocol
    private let router: (CodableError) -> any UserFacingError
    
    @Binding private var isError: CodableError?
    @Environment(\.errorResponder) private var errorResponder
    
    public init(isError: Binding<CodableError?>,
                  localizeBundle: any EnvironmentBundleProtocol,
                  router: @escaping (CodableError) -> any UserFacingError)
    {
        _isError = isError
        self.bundle = localizeBundle
        self.router = router
    }
    
    public func body(content: Content) -> some View {
        content
            .alert(anyError: self.isUserFacingError,
                   bundle:   self.bundle,
                   onDismiss: { _ in })
    }
    
    private var isUserFacingError: Binding<UserFacingError?> {
        Binding {
            guard let error = self.isError else { return nil }
            return self.router(error)
        } set: {
            guard $0 == nil else { return }
            self.isError = nil
        }
    }
}
