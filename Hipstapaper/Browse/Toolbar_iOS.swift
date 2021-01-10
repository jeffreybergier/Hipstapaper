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

#if os(macOS)
#else
internal struct Toolbar_iOS: ViewModifier {
    
    @ObservedObject var viewModel: ViewModel
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
                .popover(isPresented: self.$viewModel.browserDisplay.isSharing) {
                    Share(items: [self.viewModel.originalURL],
                          completion: { self.viewModel.browserDisplay.isSharing = false })
                }
            content
                .navigationTitle(self.viewModel.browserDisplay.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        return NavigationView {
            return self.isCompact
                ? AnyView(newContent.modifier(Toolbar_Compact(viewModel: self.viewModel)))
                : AnyView(newContent.modifier(Toolbar_Regular(viewModel: self.viewModel)))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private struct Toolbar_Compact: ViewModifier {
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.openURL) private var openURL
    
    func body(content: Content) -> some View {
        content.toolbar(id: "Browser_Compact") {
            //
            // Bottom Navigation
            //
            ToolbarItem(id: "Browser_Compact.Back", placement: .bottomBar) {
                ButtonToolbar(systemName: "chevron.backward", accessibilityLabel: "Go Back") {
                    self.viewModel.browserControl.goBack = true
                }
                .keyboardShortcut("[")
                .disabled(!self.viewModel.browserDisplay.canGoBack)
            }
            ToolbarItem(id: "Browser_Compact.Forward", placement: .bottomBar) {
                ButtonToolbar(systemName: "chevron.forward", accessibilityLabel: "Go Forward") {
                    self.viewModel.browserControl.goForward = true
                }
                .keyboardShortcut("]")
                .disabled(!self.viewModel.browserDisplay.canGoForward)
            }
            ToolbarItem(id: "Browser_Compact.Reload", placement: .bottomBar) {
                ButtonToolbarStopReload(isLoading: self.viewModel.browserDisplay.isLoading,
                                        // TODO: Check for memory leaks here
                                        stopAction: { self.viewModel.browserControl.stop = true },
                                        reloadAction: { self.viewModel.browserControl.reload = true })
            }
            // TODO: LEAKING!
            ToolbarItem(id: "Browser_Compact.JS", placement: .bottomBar) {
                ButtonToolbarJavascript(self.$viewModel.itemDisplay.isJSEnabled)
                    .keyboardShortcut("j")
            }
            //
            // Bottom Open in Options
            //
            // TODO: LEAKING!
            ToolbarItem(id: "Browser_Compact.OpenInExternal", placement: .bottomBar) {
                return ButtonToolbarBrowserExternal { self.openURL(self.viewModel.originalURL) }
                    .keyboardShortcut("O")
            }

            //
            // Top [Share] - [AddressBar] - [Done]
            //
            ToolbarItem(id: "Browser_Compact.Share", placement: .cancellationAction) {
                ButtonToolbarShare { self.viewModel.browserDisplay.isSharing = true }
                    .keyboardShortcut("i")
            }
            ToolbarItem(id: "Browser_Compact.Done", placement: .primaryAction) {
                ButtonDone(Verb.Done, action: { self.viewModel.doneAction?() })
                    .keyboardShortcut("w")
                    .disabled(self.viewModel.doneAction == nil)
            }
        }
    }
}

private struct Toolbar_Regular: ViewModifier {
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.openURL) private var openURL
    
    func body(content: Content) -> some View {
        content.toolbar(id: "Browser_Regular") {
            //
            // Bottom [JS] - [Open1] - [Open2]
            //
            // TODO: LEAKING!
            ToolbarItem(id: "Browser_Regular.JS", placement: .bottomBar) {
                ButtonToolbarJavascript(self.$viewModel.itemDisplay.isJSEnabled)
                    .keyboardShortcut("j")
            }
            // TODO: LEAKING!
            ToolbarItem(id: "Browser_Regular.OpenInExternal", placement: .bottomBar) {
                ButtonToolbarBrowserExternal { self.openURL(self.viewModel.originalURL) }
                    .keyboardShortcut("O")
            }
            
            //
            // Top Leading
            //
            ToolbarItem(id: "Browser_Regular.Back", placement: .bottomBar) {
                ButtonToolbar(systemName: "chevron.backward", accessibilityLabel: "Go Back") {
                    self.viewModel.browserControl.goBack = true
                }
                .keyboardShortcut("[")
                .disabled(!self.viewModel.browserDisplay.canGoBack)
            }
            ToolbarItem(id: "Browser_Regular.Forward", placement: .bottomBar) {
                ButtonToolbar(systemName: "chevron.forward", accessibilityLabel: "Go Forward") {
                    self.viewModel.browserControl.goForward = true
                }
                .keyboardShortcut("]")
                .disabled(!self.viewModel.browserDisplay.canGoForward)
            }
            ToolbarItem(id: "Browser_Compact.Reload", placement: .bottomBar) {
                ButtonToolbarStopReload(isLoading: self.viewModel.browserDisplay.isLoading,
                                        // TODO: Check for memory leaks here
                                        stopAction: { self.viewModel.browserControl.stop = true },
                                        reloadAction: { self.viewModel.browserControl.reload = true })
            }
            
            //
            // [Top Leading] - [AddressBar] - [Share][Done]
            //
            ToolbarItem(id: "Browser_Regular.AddressBar", placement: .principal) {
                TextField.WebsiteTitle(self.$viewModel.browserDisplay.title)
                    .disabled(true)
                    .frame(width: 400) // TODO: Remove hack when toolbar can manage width properly
            }
            ToolbarItem(id: "Browser_Regular.Share", placement: .cancellationAction) {
                ButtonToolbarShare { self.viewModel.browserDisplay.isSharing = true }
                    .keyboardShortcut("i")
            }
            ToolbarItem(id: "Browser_Regular.Done", placement: .primaryAction) {
                ButtonDone(Verb.Done, action: { self.viewModel.doneAction?() })
                    .keyboardShortcut("w")
                    .disabled(self.viewModel.doneAction == nil)
            }
        }
    }
}
#endif
