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
import Umbrella
import Stylize
import Localize

#if os(macOS)
#else
internal struct Toolbar_iOS: ViewModifier {
    
    @ObservedObject var viewModel: ViewModel
    @State private var popoverAlignment: Alignment = .topTrailing
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @ViewBuilder func body(content: Content) -> some View {
        NavigationView {
            ZStack(alignment: self.popoverAlignment) {
                Color.clear.frame(width: 1, height: 1)
                    .popover(isPresented: self.$viewModel.browserDisplay.isSharing) {
                        STZ.SHR(items: self.viewModel.originalURL.map { [$0] } ?? [],
                                completion: { self.viewModel.browserDisplay.isSharing = false })
                    }
                if self.horizontalSizeClass?.isCompact == true {
                    content
                        .modifier(Toolbar_Compact(viewModel: self.viewModel,
                                                  popoverAlignment: self.$popoverAlignment))
                } else {
                    content
                        .modifier(Toolbar_Regular(viewModel: self.viewModel,
                                                  popoverAlignment: self.$popoverAlignment))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private struct Toolbar_Compact: ViewModifier {
    
    @ObservedObject var viewModel: ViewModel
    @Binding var popoverAlignment: Alignment
    @Environment(\.openURL) private var openURL
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(self.viewModel.browserDisplay.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(id: "Browser_Compact") {
                //
                // Bottom Navigation
                //
                ToolbarItem(id: "Browser_Compact.Back", placement: .bottomBar) {
                    TH.goBackButton(self.viewModel)
                }
                ToolbarItem(id: "Browser_Compact.Forward", placement: .bottomBar) {
                    TH.goForwardButton(self.viewModel)
                }
                ToolbarItem(id: "Detail.Separator", placement: .bottomBar) {
                    STZ.TB.Separator.toolbar()
                }
                ToolbarItem(id: "Browser_Compact.Reload", placement: .bottomBar) {
                    TH.stopReloadButton(self.viewModel)
                }
                ToolbarItem(id: "Detail.FlexibleSpace", placement: .bottomBar) {
                    Spacer()
                }
                // TODO: LEAKING!
                ToolbarItem(id: "Browser_Compact.OpenInExternal", placement: .bottomBar) {
                    TH.openExternalButton(self.viewModel, self.openURL)
                }
                ToolbarItem(id: "Detail.Separator", placement: .bottomBar) {
                    STZ.TB.Separator.toolbar()
                }
                ToolbarItem(id: "Browser_Compact.Share", placement: .bottomBar) {
                    TH.shareButton {
                        self.popoverAlignment = .bottomTrailing
                        self.viewModel.browserDisplay.isSharing = true
                    }
                }
                //
                // Top bar
                //
                // TODO: LEAKING!
                ToolbarItem(id: "Browser_Compact.JS", placement: .cancellationAction) {
                    TH.jsButton(self.viewModel)
                }
                ToolbarItem(id: "Browser_Compact.Done", placement: .confirmationAction) {
                    TH.doneButton(self.viewModel)
                }
            }
    }
}

private struct Toolbar_Regular: ViewModifier {
    
    @ObservedObject var viewModel: ViewModel
    @Binding var popoverAlignment: Alignment
    @Environment(\.openURL) private var openURL
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(self.viewModel.browserDisplay.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(id: "Browser_Regular") {
                ToolbarItem(id: "Browser_Regular.Back", placement: .cancellationAction) {
                    TH.goBackButton(self.viewModel)
                }
                ToolbarItem(id: "Browser_Regular.Forward", placement: .cancellationAction) {
                    TH.goForwardButton(self.viewModel)
                }
                ToolbarItem(id: "Browser_Compact.Reload", placement: .cancellationAction) {
                    TH.stopReloadButton(self.viewModel)
                }
                // TODO: LEAKING!
                ToolbarItem(id: "Browser_Regular.JS", placement: .cancellationAction) {
                    TH.jsButton(self.viewModel)
                }
                ToolbarItem(id: "Browser_Regular.AddressBar", placement: .principal) {
                    TH.addressBar(self.$viewModel.browserDisplay.title)
                        .frame(width: 400) // TODO: Remove hack when toolbar can manage width properly
                }
                // TODO: LEAKING!
                ToolbarItem(id: "Browser_Regular.OpenInExternal", placement: .automatic) {
                    TH.openExternalButton(self.viewModel, self.openURL)
                }
                ToolbarItem(id: "Browser_Regular.Share", placement: .automatic) {
                    TH.shareButton {
                        self.popoverAlignment = .topTrailing
                        self.viewModel.browserDisplay.isSharing = true
                    }
                }
                ToolbarItem(id: "Browser_Regular.Done", placement: .confirmationAction) {
                    TH.doneButton(self.viewModel)
                }
            }
    }
}
#endif
