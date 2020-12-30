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

internal struct Toolbar: ViewModifier {
    
    @ObservedObject var control: WebView.Control
    @ObservedObject var display: WebView.Display
    
    // Unused on Mac
    let done: (() -> Void)?
    // Unused on Mac
    let openInNewWindow: (() -> Void)?
    
    @State var shareSheetPresented = false
    @Environment(\.openURL) var openURL
    
    // TODO: Remove this copy paste BS when NSWindow works properly
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Stylize.Toolbar {
                HStack(spacing: 16) {
                    ButtonToolbar(systemName: "chevron.backward", accessibilityLabel: "Go Back") {
                        self.control.goBack = true
                    }
                    .keyboardShortcut("[")
                    .disabled(!self.display.canGoBack)
                    
                    ButtonToolbar(systemName: "chevron.forward", accessibilityLabel: "Go Forward") {
                        self.control.goForward = true
                    }
                    .keyboardShortcut("]")
                    .disabled(!self.display.canGoForward)
                    
                    ButtonToolbarStopReload(isLoading: self.display.isLoading,
                                            stopAction: { self.control.stop = true },
                                            reloadAction: { self.control.reload = true })
                    
                    ButtonToolbarJavascript(isJSEnabled: self.control.isJSEnabled,
                                            toggleAction: { self.control.isJSEnabled.toggle() })
                        .keyboardShortcut("j")
                    
                    TextField.WebsiteTitle(self.$display.title).disabled(true)
                    
                    ButtonToolbarShare { self.shareSheetPresented = true }
                        .keyboardShortcut("i")
                        .popover(isPresented: self.$shareSheetPresented) {
                            Share([self.control.originalLoad]) { self.shareSheetPresented = false }
                        }
                    
                    ButtonToolbarBrowserExternal { self.openURL(self.control.originalLoad) }
                        .keyboardShortcut("O")
                }
            }
            .buttonStyle(PlainButtonStyle())
            content
                .navigationTitle(self.display.title)
        }
    }
}

#endif
