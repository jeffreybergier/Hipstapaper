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
import Localize

#if os(macOS)

internal struct Toolbar_macOS: ViewModifier {
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.openURL) var openURL
    
    // TODO: Remove this copy paste BS when NSWindow works properly
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Stylize.Toolbar {
                HStack(spacing: 16) {
                    ButtonToolbar(systemName: "chevron.backward", accessibilityLabel: "Go Back") {
                        self.viewModel.browserControl.goBack = true
                    }
                    .keyboardShortcut("[")
                    .disabled(!self.viewModel.browserDisplay.canGoBack)
                    
                    ButtonToolbar(systemName: "chevron.forward", accessibilityLabel: "Go Forward") {
                        self.viewModel.browserControl.goForward = true
                    }
                    .keyboardShortcut("]")
                    .disabled(!self.viewModel.browserDisplay.canGoForward)
                    
                    ButtonToolbarStopReload(isLoading: self.viewModel.browserDisplay.isLoading,
                                            // TODO: Check for memory leaks here
                                            stopAction: { self.viewModel.browserControl.stop = true },
                                            reloadAction: { self.viewModel.browserControl.reload = true })
                    
                    ButtonToolbarJavascript(self.$viewModel.itemDisplay.isJSEnabled)
                        .keyboardShortcut("j")
                    
                    TextField.WebsiteTitle(self.$viewModel.browserDisplay.title)
                        .disabled(true)
                    
                    ButtonToolbarShare { self.viewModel.browserDisplay.isSharing = true }
                        .keyboardShortcut("i")
                    
                    STZ.TB.OpenInBrowser.toolbarButton(action: { self.openURL(self.viewModel.originalURL) })
                    
                    if let done = self.viewModel.doneAction {
                        ButtonDone(Verb.Done, action: done)
                            .keyboardShortcut("w")
                    }
                }
            }
            .modifier(STZ_BorderedButtonStyle())
            content
                .navigationTitle(self.viewModel.browserDisplay.title)
        }
    }
}

#endif
