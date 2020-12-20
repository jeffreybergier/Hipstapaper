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

internal struct Toolbar: View {

    @ObservedObject var control: WebView.Control
    @ObservedObject var display: WebView.Display
    
    var body: some View {
        Stylize.Toolbar {
            VStack {
                HStack {
                    ButtonToolbar(systemName: "chevron.backward", accessibilityLabel: "Go Back") {
                        self.control.goBack = true
                    }
                    .disabled(!self.display.canGoBack)
                    ButtonToolbar(systemName: "chevron.forward", accessibilityLabel: "Go Forward") {
                        self.control.goForward = true
                    }
                    .disabled(!self.display.canGoForward)
                    if self.display.isLoading {
                        ButtonToolbar(systemName: "xmark", accessibilityLabel: "Stop") {
                            self.control.stop = true
                        }
                        .disabled(!self.display.isLoading)
                    } else {
                        ButtonToolbar(systemName: "arrow.clockwise", accessibilityLabel: "Reload") {
                            self.control.reload = true
                        }
                        .disabled(self.display.isLoading)
                    }
                    TextField.WebsiteTitle(self.$display.title).disabled(true)
                    ButtonToolbar(systemName: self.control.isJSEnabled ? "applescript.fill" : "applescript", accessibilityLabel: "Javascript") {
                        self.control.isJSEnabled.toggle()
                    }
                }
                if self.display.isLoading {
                    ProgressBar(self.display.progress)
                }
            }
        }.animation(.default)
    }

}
