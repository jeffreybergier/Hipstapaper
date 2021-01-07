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

import Combine
import AppKit
import SwiftUI
import Browse

class BrowserWindowController: NSWindowController {
    
    let url: URL
    var windowWillClose: ((URL) -> Void)?
    var browserToken: AnyCancellable?
    
    init(url: URL) {
        self.url = url
        super.init(window: nil)
        self.windowFrameAutosaveName = url.absoluteString
    }
    
    override func showWindow(_ sender: Any?) {
        if self.window == nil {
            let vm = Browse.ViewModel(url: self.url, doneAction: nil)
            self.browserToken = vm.$browserDisplay.sink()
            { [weak self] display in
                // WindowController DEINIT happens before Browser
                // If title changed in this small instant, could crash
                // if using unowned reference
                self?.window?.title = display.title
            }
            let browser = Browser(vm)
            let vc = NSHostingController(rootView: browser)
            let window = NSWindow(contentViewController: vc)
            window.delegate = self
            self.window = window
        }
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
