//
//  Created by Jeffrey Bergier on 2020/12/20.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
    
    @Localize private var text
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
                    TH.goBackButton(self.viewModel, bundle: self.text)
                }
                ToolbarItem(id: "Browser_Compact.Forward", placement: .bottomBar) {
                    TH.goForwardButton(self.viewModel, bundle: self.text)
                }
                ToolbarItem(id: "Detail.Separator", placement: .bottomBar) {
                    STZ.TB.Separator.toolbar()
                }
                ToolbarItem(id: "Browser_Compact.Reload", placement: .bottomBar) {
                    TH.stopReloadButton(self.viewModel, bundle: self.text)
                }
                ToolbarItem(id: "Detail.FlexibleSpace", placement: .bottomBar) {
                    Spacer()
                }
                // TODO: LEAKING!
                ToolbarItem(id: "Browser_Compact.OpenInExternal", placement: .bottomBar) {
                    TH.openExternalButton(self.viewModel, bundle: self.text, self.openURL)
                }
                ToolbarItem(id: "Detail.Separator", placement: .bottomBar) {
                    STZ.TB.Separator.toolbar()
                }
                ToolbarItem(id: "Browser_Compact.Share", placement: .bottomBar) {
                    TH.shareButton(bundle: self.text) {
                        self.popoverAlignment = .bottomTrailing
                        self.viewModel.browserDisplay.isSharing = true
                    }
                }
                //
                // Top bar
                //
                // TODO: LEAKING!
                ToolbarItem(id: "Browser_Compact.JS", placement: .cancellationAction) {
                    TH.jsButton(self.viewModel, bundle: self.text)
                }
                ToolbarItem(id: "Browser_Compact.Done", placement: .confirmationAction) {
                    TH.doneButton(self.viewModel)
                }
            }
    }
}

private struct Toolbar_Regular: ViewModifier {
    
    @Localize private var text
    @ObservedObject var viewModel: ViewModel
    @Binding var popoverAlignment: Alignment
    @Environment(\.openURL) private var openURL
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(self.viewModel.browserDisplay.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(id: "Browser_Regular") {
                ToolbarItem(id: "Browser_Regular.Back", placement: .cancellationAction) {
                    TH.goBackButton(self.viewModel, bundle: self.text)
                }
                ToolbarItem(id: "Browser_Regular.Forward", placement: .cancellationAction) {
                    TH.goForwardButton(self.viewModel, bundle: self.text)
                }
                ToolbarItem(id: "Browser_Compact.Reload", placement: .cancellationAction) {
                    TH.stopReloadButton(self.viewModel, bundle: self.text)
                }
                // TODO: LEAKING!
                ToolbarItem(id: "Browser_Regular.JS", placement: .cancellationAction) {
                    TH.jsButton(self.viewModel, bundle: self.text)
                }
                ToolbarItem(id: "Browser_Regular.AddressBar", placement: .principal) {
                    TH.addressBar(self.$viewModel.browserDisplay.title)
                        .frame(width: 400) // TODO: Remove hack when toolbar can manage width properly
                }
                // TODO: LEAKING!
                ToolbarItem(id: "Browser_Regular.OpenInExternal", placement: .automatic) {
                    TH.openExternalButton(self.viewModel, bundle: self.text, self.openURL)
                }
                ToolbarItem(id: "Browser_Regular.Share", placement: .automatic) {
                    TH.shareButton(bundle: self.text) {
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
