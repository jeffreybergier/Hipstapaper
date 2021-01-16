//
//  Created by Jeffrey Bergier on 2020/12/29.
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

import AppKit
import Combine

class WindowPresentation: ObservableObject, WindowManagerProtocol {
    
    private var windows: [URL: BrowserWindowController] = [:]
    
    let features: Features = [.multipleWindows, .bulkActivation]

    func show(_ urls: Set<URL>, error: @escaping (Error) -> Void) {
        for url in urls {
            let window = self.windows[url] ?? BrowserWindowController(url: url)
            self.windows[url] = window
            window.windowWillClose = { [unowned self] url in
                self.windows.removeValue(forKey: url)
            }
            window.showWindow(self)
        }
    }
}
