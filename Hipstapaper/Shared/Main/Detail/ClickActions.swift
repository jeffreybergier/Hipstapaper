//
//  Created by Jeffrey Bergier on 2021/01/03.
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
import Datum
import Browse

enum ClickActions {
    struct SingleClick: ViewModifier {
        
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        let item: AnyElement<AnyWebsite>

        func body(content: Content) -> some View {
            #if os(macOS)
            return content
            #else
            return Button(action: { self.modalPresentation.value = .browser(item) },
                          label: { content })
            #endif
        }
    }
}
