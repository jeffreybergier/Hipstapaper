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
import Stylize
import Datum

struct WebsiteDelete: ViewModifier {
    
    let controller: Controller
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var errorQ: STZ.ERR.ViewModel
    
    func body(content: Content) -> some View {
        content.alert(item: self.$modalPresentation.isDelete) { selection in
            Alert(
                // TODO: Localized and fix this
                title: STZ.VIEW.TXT("Delete"),
                message: STZ.VIEW.TXT("This action cannot be undone."),
                primaryButton: .destructive(STZ.VIEW.TXT("Delete"),
                                            action: { WH.delete(selection, self.controller, self.errorQ) }),
                secondaryButton: .cancel()
            )
        }
    }
}
