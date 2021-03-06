//
//  Created by Jeffrey Bergier on 2021/02/07.
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

internal typealias TH = ToolbarHelper

internal enum ToolbarHelper {
    @ViewBuilder static func stopReloadButton(_ viewModel: ViewModel) -> some View {
        if viewModel.browserDisplay.isLoading {
            STZ.TB.Stop.__fake_macOS_toolbar(action: { viewModel.browserControl.stop = true })
        } else {
            STZ.TB.Reload.__fake_macOS_toolbar(action: { viewModel.browserControl.reload = true })
        }
    }
    
    @ViewBuilder static func jsButton(_ viewModel: ViewModel) -> some View {
        if viewModel.itemDisplay.isJSEnabled {
            STZ.TB.JSActive.__fake_macOS_toolbar(action: { viewModel.itemDisplay.isJSEnabled = false })
        } else {
            STZ.TB.JSInactive.__fake_macOS_toolbar(action: { viewModel.itemDisplay.isJSEnabled = true })
        }
    }
    
    static func goForwardButton(_ viewModel: ViewModel) -> some View {
        STZ.TB.GoForward.__fake_macOS_toolbar(isEnabled: viewModel.browserDisplay.canGoForward,
                                              action: { viewModel.browserControl.goForward = true })
    }
    
    static func goBackButton(_ viewModel: ViewModel) -> some View {
        STZ.TB.GoBack.__fake_macOS_toolbar(isEnabled: viewModel.browserDisplay.canGoBack,
                                           action: { viewModel.browserControl.goBack = true })
    }
    
    static func doneButton(_ viewModel: ViewModel) -> some View {
        STZ.BTN.BrowserDone.button(doneStyle: true,
                                   isEnabled: viewModel.doneAction != nil,
                                   action: { viewModel.doneAction?() })
    }
    
    static func shareButton(action: @escaping Action) -> some View {
        STZ.TB.Share.__fake_macOS_toolbar(action: action)
    }
    
    static func openExternalButton(_ viewModel: ViewModel, _ openURL: OpenURLAction) -> some View {
        let urlBuilder = { URL(string: viewModel.browserDisplay.urlString) ?? viewModel.originalURL }
        return STZ.TB.OpenInBrowser.__fake_macOS_toolbar(isEnabled: urlBuilder() != nil) {
            guard let url = urlBuilder() else { return }
            openURL(url)
        }
    }
    
    static func addressBar(_ title: Binding<String>) -> some View {
        STZ.VIEW.TXTFLD.WebTitle.textfield(title)
            .disabled(true)
    }
}
