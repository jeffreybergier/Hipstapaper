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
            Stylize.Toolbar {
                HStack(spacing: 16) {
                    STZ.TB.GoBack.toolbar(isDisabled: !self.viewModel.browserDisplay.canGoBack,
                                                action: { self.viewModel.browserControl.goBack = true })
                    
                    STZ.TB.GoForward.toolbar(isDisabled: !self.viewModel.browserDisplay.canGoForward,
                                                action: { self.viewModel.browserControl.goForward = true })
                    
                    self.viewModel.browserDisplay.isLoading
                        ? AnyView(STZ.TB.Stop.toolbar(action: { self.viewModel.browserControl.stop = true }))
                        : AnyView(STZ.TB.Reload.toolbar(action: { self.viewModel.browserControl.reload = true }))
                    
                    self.viewModel.itemDisplay.isJSEnabled
                        ? AnyView(STZ.TB.JSActive.toolbar(action: { self.viewModel.itemDisplay.isJSEnabled = false }))
                        : AnyView(STZ.TB.JSInactive.toolbar(action: { self.viewModel.itemDisplay.isJSEnabled = true }))
                    
                    TextField.WebsiteTitle(self.$viewModel.browserDisplay.title)
                        .disabled(true)
                    
                    STZ.TB.Share.toolbar(action: { self.viewModel.browserDisplay.isSharing = true })
                    
                    STZ.TB.OpenInBrowser.toolbar(action: { self.openURL(self.viewModel.originalURL) })
                    
                    if let done = self.viewModel.doneAction {
                        STZ.BTN.BrowserDone.button(action: done)
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())
            content
                .navigationTitle(self.viewModel.browserDisplay.title)
        }
    }
}

#endif
