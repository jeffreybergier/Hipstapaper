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

import SwiftUI
import Stylize

#if os(macOS)

internal struct Toolbar_macOS: ViewModifier {
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.openURL) var openURL
    
    // TODO: Remove this copy paste BS when NSWindow works properly
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                TH.goBackButton(self.viewModel)
                TH.goForwardButton(self.viewModel)
                TH.stopReloadButton(self.viewModel)
                TH.jsButton(self.viewModel)
                TH.addressBar(self.$viewModel.browserDisplay.title)
                TH.shareButton(action: { self.viewModel.browserDisplay.isSharing = true })
                TH.openExternalButton(self.viewModel, self.openURL)
                if let done = self.viewModel.doneAction {
                    STZ.BTN.BrowserDone.button(action: done)
                }
            }
            .modifier(STZ.VIEW.TB_HACK())
            .buttonStyle(BorderedButtonStyle())
            content
        }
    }
}

#endif
