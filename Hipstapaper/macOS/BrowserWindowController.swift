//
//  Created by Jeffrey Bergier on 2020/12/25.
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
import Browse
import SwiftUI

class BrowserWindowController: NSWindowController {
    
    let url: URL
    var windowWillClose: ((URL) -> Void)?
    
    init(url: URL) {
        self.url = url
        super.init(window: nil)
        self.windowFrameAutosaveName = url.absoluteString
    }
    
    override func showWindow(_ sender: Any?) {
        let browser = Browser(url: url,
                              openInNewWindow: nil,
                              done: { [unowned self] in self.close() })
        let vc = NSHostingController(rootView: browser)
        let window = NSWindow(contentViewController: vc)
        window.delegate = self
        self.window = window
        super.showWindow(sender)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BrowserWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        self.windowWillClose?(self.url)
    }
}
