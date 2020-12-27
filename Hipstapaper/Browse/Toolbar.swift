//
//  Created by Jeffrey Bergier on 2020/12/20.
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

internal struct Toolbar: ViewModifier {

    @ObservedObject var control: WebView.Control
    @ObservedObject var display: WebView.Display
    @State var shareSheetPresented = false
    @Environment(\.openURL) var openURL
    
    func body(content: Content) -> some View {
        NavigationView {
            content
                .navigationTitle("Hello")
                .toolbar(id: "Browser") {
                    ToolbarItem(id: "0", placement: ToolbarItemPlacement.navigation) {
                        ButtonToolbar(systemName: "chevron.backward", accessibilityLabel: "Go Back") {
                            self.control.goBack = true
                        }
                        .keyboardShortcut("[")
                        .disabled(!self.display.canGoBack)
                    }
                    ToolbarItem(id: "0", placement: ToolbarItemPlacement.navigation) {
                        ButtonToolbar(systemName: "chevron.forward", accessibilityLabel: "Go Forward") {
                            self.control.goForward = true
                        }
                        .keyboardShortcut("]")
                        .disabled(!self.display.canGoForward)
                    }
                    ToolbarItem(id: "0", placement: ToolbarItemPlacement.navigation) {
                        ButtonToolbarStopReload(isLoading: self.display.isLoading,
                                                stopAction: { self.control.stop = true },
                                                reloadAction: { self.control.reload = true })
                    }
                    ToolbarItem(id: "0", placement: ToolbarItemPlacement.navigation) {
                        ButtonToolbarJavascript(isJSEnabled: self.control.isJSEnabled,
                                                toggleAction: { self.control.isJSEnabled.toggle() })
                            .keyboardShortcut("j")
                    }
                    ToolbarItem(id: "0", placement: ToolbarItemPlacement.principal) {
                        TextField.WebsiteTitle(self.$display.title).disabled(true)
                    }
                    ToolbarItem(id: "0", placement: ToolbarItemPlacement.primaryAction) {
                        ButtonToolbarShare { self.shareSheetPresented = true }
                            .keyboardShortcut("i")
                            .popover(isPresented: self.$shareSheetPresented) {
                                Share([self.control.originalLoad]) { self.shareSheetPresented = false }
                            }
                    }
                    ToolbarItem(id: "0", placement: ToolbarItemPlacement.primaryAction) {
                        ButtonToolbarSafari { self.openURL(self.control.originalLoad) }
                            .keyboardShortcut("O")
                    }
                }
        }
    }
    
//    var body: some View {
//        Stylize.Toolbar {
//            VStack {
//                HStack {
//
//
//
//
//                }
//                if self.display.isLoading {
//                    ProgressBar(self.display.progress)
//                        .opacity(self.display.isLoading ? 1 : 0)
//                }
//            }
//        }.animation(.default)
//    }

}
