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

#if canImport(UIKit)
internal struct Toolbar: ViewModifier {
    
    @ObservedObject var control: WebView.Control
    @ObservedObject var display: WebView.Display
    let done: () -> Void
    let openInNewWindow: (() -> Void)?
            
    func body(content: Content) -> some View {
        return NavigationView {
            content
                .navigationBarTitle(self.display.title, displayMode: .inline)
                .modifier(ShareToolbar_Leading(control: self.control))
                .modifier(NavigationToolbar(control: self.control, display: self.display))
                .toolbar(id: "Browser") {
                    ToolbarItem(id: "Browser.5", placement: ToolbarItemPlacement.principal) {
                        TextField.WebsiteTitle(self.$display.title).disabled(true)
                    }
                }
                .modifier(BrowserToolbar(control: self.control, openInNewWindow: self.openInNewWindow))
                .modifier(ShareToolbar_Trailing(control: self.control))
                .toolbar(id: "Browser") {
                    ToolbarItem(id: "Browser.9", placement: .primaryAction) {
                        ButtonDone(Verb.Done, action: self.done)
                            .keyboardShortcut("w")
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ShareToolbar_Leading: ViewModifier {
    
    @ObservedObject var control: WebView.Control
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
        guard isCompact else { return AnyView(content) }
        // TODO: Remove hack when toolbar presentations work
        return AnyView(
            ZStack(alignment: .topLeading) {
                Color.clear.frame(width: 1, height: 1)
                    .popover(isPresented: self.$shareSheetPresented) {
                        Share([self.control.originalLoad]) { self.shareSheetPresented = false }
                    }
                content
                    .toolbar(id: "Browser") {
                        ToolbarItem(id: "Browser.6", placement: .cancellationAction) {
                            ButtonToolbarShare { self.shareSheetPresented = true }
                                .keyboardShortcut("i")
                        }
                    }
            }
        )
    }
}

struct ShareToolbar_Trailing: ViewModifier {
    
    @ObservedObject var control: WebView.Control
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
        guard !isCompact else { return AnyView(content) }
        // TODO: Remove hack when toolbar presentations work
        return AnyView(
            ZStack(alignment: .topTrailing) {
                Color.clear.frame(width: 1, height: 1)
                    .popover(isPresented: self.$shareSheetPresented) {
                        Share([self.control.originalLoad]) { self.shareSheetPresented = false }
                    }
                content
                    .toolbar(id: "Browser") {
                        ToolbarItem(id: "Browser.6", placement: .automatic) {
                            ButtonToolbarShare { self.shareSheetPresented = true }
                                .keyboardShortcut("i")
                        }
                    }
            }
        )
    }
}

struct BrowserToolbar: ViewModifier {
    
    @ObservedObject var control: WebView.Control
    let openInNewWindow: (() -> Void)?
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var placement: ToolbarItemPlacement {
        switch self.horizontalSizeClass ?? .compact {
        case .regular:
            return .automatic
        case .compact:
            fallthrough
        @unknown default:
            return .bottomBar
        }
    }
    
    func body(content: Content) -> some View {
        if let open = self.openInNewWindow {
            return AnyView(content
                .toolbar(id: "Browser") {
                    ToolbarItem(id: "Browser.7", placement: self.placement) {
                        ButtonToolbarBrowserInApp { open() }
                            .keyboardShortcut("o")
                    }
                    ToolbarItem(id: "Browser.8", placement: self.placement) {
                        ButtonToolbarBrowserExternal { self.openURL(self.control.originalLoad) }
                            .keyboardShortcut("O")
                    }
                })
        } else {
            return AnyView(content
                .toolbar(id: "Browser") {
                    ToolbarItem(id: "Browser.8", placement: self.placement) {
                        ButtonToolbarBrowserExternal { self.openURL(self.control.originalLoad) }
                            .keyboardShortcut("O")
                    }
                })
        }
    }
}

struct NavigationToolbar: ViewModifier {
    
    @ObservedObject var control: WebView.Control
    @ObservedObject var display: WebView.Display
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var placement: ToolbarItemPlacement {
        switch self.horizontalSizeClass ?? .compact {
        case .regular:
            return .navigation
        case .compact:
            fallthrough
        @unknown default:
            return .bottomBar
        }
    }
        
    func body(content: Content) -> some View {
        content.toolbar(id: "Browser") {
            ToolbarItem(id: "Browser.1", placement: self.placement) {
                ButtonToolbar(systemName: "chevron.backward", accessibilityLabel: "Go Back") {
                    self.control.goBack = true
                }
                .keyboardShortcut("[")
                .disabled(!self.display.canGoBack)
            }
            ToolbarItem(id: "Browser.2", placement: self.placement) {
                ButtonToolbar(systemName: "chevron.forward", accessibilityLabel: "Go Forward") {
                    self.control.goForward = true
                }
                .keyboardShortcut("]")
                .disabled(!self.display.canGoForward)
            }
            ToolbarItem(id: "Browser.3", placement: self.placement) {
                ButtonToolbarStopReload(isLoading: self.display.isLoading,
                                        stopAction: { self.control.stop = true },
                                        reloadAction: { self.control.reload = true })
            }
            ToolbarItem(id: "Browser.4", placement: self.placement) {
                ButtonToolbarJavascript(isJSEnabled: self.control.isJSEnabled,
                                        toggleAction: { self.control.isJSEnabled.toggle() })
                    .keyboardShortcut("j")
            }
        }
    }
}

#endif
