//
//  Created by Jeffrey Bergier on 2020/12/31.
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

struct Toolbar: ViewModifier {
    
    @ObservedObject var control: WebView.Control
    @ObservedObject var display: WebView.Display
    
    let done: () -> Void
    let openInNewWindow: (() -> Void)?
    
    #if os(macOS)
    func body(content: Content) -> some View {
        return content.modifier(Toolbar_macOS(control: self.control,
                                            display: self.display))
    }
    #else
    func body(content: Content) -> some View {
        return content.modifier(Toolbar_iOS(control: self.control,
                                            display: self.display,
                                            done: self.done,
                                            openInNewWindow: self.openInNewWindow))
    }
    #endif
}