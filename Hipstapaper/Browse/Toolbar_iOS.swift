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
import Localize

internal struct Toolbar_Wrap: ViewModifier {
    
    @ObservedObject var control: WebView.Control
    @ObservedObject var display: WebView.Display
    
    let done: () -> Void
    let openInNewWindow: (() -> Void)?
    
    @State private var shareSheetPresented = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        switch self.horizontalSizeClass ?? .compact {
        case .regular:
            return false
        case .compact:
            fallthrough
        @unknown default:
            return true
        }
    }
    
    func body(content: Content) -> some View {
        // TODO remove this hack once toolbars support popovers
        let newContent = ZStack(alignment: self.isCompact ? .topLeading : .topTrailing) {
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$shareSheetPresented) {
                    Share([self.control.originalLoad]) { self.shareSheetPresented = false }
                }
            content
                .navigationTitle(self.display.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        return NavigationView {
            return self.isCompact
                ? AnyView(newContent.modifier(Toolbar_Compact(control: self.control,
                                                              display: self.display,
                                                              shareSheetPresented: self.$shareSheetPresented,
                                                              done: self.done,
                                                              openInNewWindow: self.openInNewWindow)))
                : AnyView(newContent.modifier(Toolbar_Regular(control: self.control,
                                                              display: self.display,
                                                              shareSheetPresented: self.$shareSheetPresented,
                                                              done: self.done,
                                                              openInNewWindow: self.openInNewWindow)))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private struct Toolbar_Compact: ViewModifier {
    
    @ObservedObject var control: WebView.Control
    @ObservedObject var display: WebView.Display
    @Binding var shareSheetPresented: Bool
    
    let done: () -> Void
    let openInNewWindow: (() -> Void)?
    
    @Environment(\.openURL) private var openURL
    
    func body(content: Content) -> some View {
        content.toolbar(id: "Browser") {
            //
            // Bottom Navigation
            //
            ToolbarItem(id: "Browser.Back", placement: .bottomBar) {
                ButtonToolbar(systemName: "chevron.backward", accessibilityLabel: "Go Back") {
                    self.control.goBack = true
                }
                .keyboardShortcut("[")
                .disabled(!self.display.canGoBack)
            }
            ToolbarItem(id: "Browser.Forward", placement: .bottomBar) {
                ButtonToolbar(systemName: "chevron.forward", accessibilityLabel: "Go Forward") {
                    self.control.goForward = true
                }
                .keyboardShortcut("]")
                .disabled(!self.display.canGoForward)
            }
            ToolbarItem(id: "Browser.Reload", placement: .bottomBar) {
                ButtonToolbarStopReload(isLoading: self.display.isLoading,
                                        stopAction: { self.control.stop = true },
                                        reloadAction: { self.control.reload = true })
            }
            ToolbarItem(id: "Browser.JS", placement: .bottomBar) {
                ButtonToolbarJavascript(isJSEnabled: self.control.isJSEnabled,
                                        toggleAction: { self.control.isJSEnabled.toggle() })
                    .keyboardShortcut("j")
            }
            //
            // Bottom Open in Options
            //
            ToolbarItem(id: "Browser.OpenInWindow", placement: .bottomBar) {
                ButtonToolbarBrowserInApp { self.openInNewWindow?() }
                    .keyboardShortcut("o")
                    .disabled({ self.openInNewWindow == nil }())
            }
            ToolbarItem(id: "Browser.OpenInExternal", placement: .bottomBar) {
                ButtonToolbarBrowserExternal { self.openURL(self.control.originalLoad) }
                    .keyboardShortcut("O")
            }
            
            //
            // Top [Share] - [AddressBar] - [Done]
            //
            ToolbarItem(id: "Browser.Share", placement: .cancellationAction) {
                ButtonToolbarShare { self.shareSheetPresented = true }
                    .keyboardShortcut("i")
            }
            ToolbarItem(id: "Browser.AddressBar", placement: .principal) {
                TextField.WebsiteTitle(self.$display.title)
                    .disabled(true)
                    .frame(width: 250) // TODO: Remove hack when toolbar can manage width properly
            }
            ToolbarItem(id: "Browser.Done", placement: .primaryAction) {
                ButtonDone(Verb.Done, action: self.done)
                    .keyboardShortcut("w")
            }
        }
    }
}

private struct Toolbar_Regular: ViewModifier {
    
    @ObservedObject var control: WebView.Control
    @ObservedObject var display: WebView.Display
    @Binding var shareSheetPresented: Bool
    
    let done: () -> Void
    let openInNewWindow: (() -> Void)?
    
    @Environment(\.openURL) private var openURL
    
    func body(content: Content) -> some View {
        content.toolbar(id: "Browser") {
            //
            // Bottom [JS] - [Open1] - [Open2]
            //
            ToolbarItem(id: "Browser.JS", placement: .bottomBar) {
                ButtonToolbarJavascript(isJSEnabled: self.control.isJSEnabled,
                                        toggleAction: { self.control.isJSEnabled.toggle() })
                    .keyboardShortcut("j")
            }
            ToolbarItem(id: "Browser.OpenInWindow", placement: .bottomBar) {
                ButtonToolbarBrowserInApp { self.openInNewWindow?() }
                    .keyboardShortcut("o")
                    .disabled({ self.openInNewWindow == nil }())
            }
            ToolbarItem(id: "Browser.OpenInExternal", placement: .bottomBar) {
                ButtonToolbarBrowserExternal { self.openURL(self.control.originalLoad) }
                    .keyboardShortcut("O")
            }
            
            //
            // Top Leading
            //
            ToolbarItem(id: "Browser.Back", placement: .navigation) {
                ButtonToolbar(systemName: "chevron.backward", accessibilityLabel: "Go Back") {
                    self.control.goBack = true
                }
                .keyboardShortcut("[")
                .disabled(!self.display.canGoBack)
            }
            ToolbarItem(id: "Browser.Forward", placement: .navigation) {
                ButtonToolbar(systemName: "chevron.forward", accessibilityLabel: "Go Forward") {
                    self.control.goForward = true
                }
                .keyboardShortcut("]")
                .disabled(!self.display.canGoForward)
            }
            ToolbarItem(id: "Browser.Reload", placement: .navigation) {
                ButtonToolbarStopReload(isLoading: self.display.isLoading,
                                        stopAction: { self.control.stop = true },
                                        reloadAction: { self.control.reload = true })
            }
            
            //
            // [Top Leading] - [AddressBar] - [Share][Done]
            //
            ToolbarItem(id: "Browser.AddressBar", placement: .principal) {
                TextField.WebsiteTitle(self.$display.title)
                    .disabled(true)
                    .frame(width: 400) // TODO: Remove hack when toolbar can manage width properly
            }
            ToolbarItem(id: "Browser.Share", placement: .automatic) {
                ButtonToolbarShare { self.shareSheetPresented = true }
                    .keyboardShortcut("i")
            }
            ToolbarItem(id: "Browser.Done", placement: .primaryAction) {
                ButtonDone(Verb.Done, action: self.done)
                    .keyboardShortcut("w")
            }
        }
    }
}
