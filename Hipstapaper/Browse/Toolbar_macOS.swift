//
//  Created by Jeffrey Bergier on 2020/12/30.
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
