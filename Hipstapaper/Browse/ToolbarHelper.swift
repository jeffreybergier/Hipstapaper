//
//  Created by Jeffrey Bergier on 2021/02/07.
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

internal typealias TH = ToolbarHelper

internal enum ToolbarHelper {
    @ViewBuilder static func stopReloadButton(_ viewModel: ViewModel) -> some View {
        if viewModel.browserDisplay.isLoading {
            STZ.TB.Stop.toolbar(action: { viewModel.browserControl.stop = true })
        } else {
            STZ.TB.Reload.toolbar(action: { viewModel.browserControl.reload = true })
        }
    }
    
    @ViewBuilder static func jsButton(_ viewModel: ViewModel) -> some View {
        if viewModel.itemDisplay.isJSEnabled {
            STZ.TB.JSActive.toolbar(action: { viewModel.itemDisplay.isJSEnabled = false })
        } else {
            STZ.TB.JSInactive.toolbar(action: { viewModel.itemDisplay.isJSEnabled = true })
        }
    }
    
    static func goForwardButton(_ viewModel: ViewModel) -> some View {
        STZ.TB.GoForward.toolbar(isEnabled: viewModel.browserDisplay.canGoForward,
                                 action: { viewModel.browserControl.goForward = true })
    }
    
    static func goBackButton(_ viewModel: ViewModel) -> some View {
        STZ.TB.GoBack.toolbar(isEnabled: viewModel.browserDisplay.canGoBack,
                              action: { viewModel.browserControl.goBack = true })
    }
    
    static func doneButton(_ viewModel: ViewModel) -> some View {
        STZ.BTN.BrowserDone.button(doneStyle: true,
                                   isEnabled: viewModel.doneAction != nil,
                                   action: { viewModel.doneAction?() })
    }
    
    static func openExternalButton(_ viewModel: ViewModel, _ openURL: OpenURLAction) -> some View {
        STZ.TB.OpenInBrowser.toolbar() {
            let url = URL(string: viewModel.browserDisplay.urlString) ?? viewModel.originalURL
            openURL(url)
        }
    }
    
    static func addressBar(_ title: Binding<String>) -> some View {
        STZ.VIEW.TXTFLD.WebTitle.textfield(title)
            .disabled(true)
    }
}
