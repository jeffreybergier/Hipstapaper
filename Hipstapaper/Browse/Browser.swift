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

public struct Browser: View {
    
    @StateObject var control: WebView.Control
    @StateObject var display: WebView.Display = .init()
    let done: () -> Void
    let openInNewWindow: (() -> Void)?
    
    public var body: some View {
        ZStack(alignment: .top) {
            WebView(control: self.control, display: self.display)
                .frame(minWidth: 300, idealWidth: 768, minHeight: 300, idealHeight: 768)
                .edgesIgnoringSafeArea(.all)
            if self.display.isLoading {
                ProgressBar(self.display.progress)
                    .opacity(self.display.isLoading ? 1 : 0)
            }
        }
        // TODO: Toolbar leaks like crazy on iOS :(
        .modifier(Toolbar(control: self.control,
                          display: self.display,
                          done: self.done,
                          openInNewWindow: self.openInNewWindow))
    }
    
    public init(url load: URL, openInNewWindow: (() -> Void)?, done: @escaping () -> Void) {
        _control = .init(wrappedValue: WebView.Control(load))
        self.done = done
        self.openInNewWindow = openInNewWindow
    }
}
