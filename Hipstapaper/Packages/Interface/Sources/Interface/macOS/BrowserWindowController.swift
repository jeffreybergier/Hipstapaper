//
//  Created by Jeffrey Bergier on 2020/12/25.
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

#if os(macOS)

import Combine
import AppKit
import SwiftUI
import Umbrella
import Datum
import Localize
import Browse

class BrowserWindowController: NSWindowController {
    
    let website: Website
    let controller: Controller
    var windowWillClose: ((Website) -> Void)?
    private var browserToken: AnyCancellable?
    
    init(website: Website, controller: Controller) {
        self.website = website
        self.controller = controller
        super.init(window: nil)
        self.windowFrameAutosaveName = website.uuid.id
    }
    
    override func showWindow(_ sender: Any?) {
        if self.window == nil {
            let vm = Browse.ViewModel(website: self.website, doneAction: nil)
            self.browserToken = vm.$browserDisplay.sink()
            { [unowned self] display in
                self.window?.title = display.title
            }
            let browser = Browser(viewModel: vm, controller: self.controller)
            let vc = NSHostingController(rootView: browser)
            let window = NSWindow(contentViewController: vc)
            window.delegate = self
            // this does not appear to override the windowFrameAutosave restore
            window.setFrame(NSRect(x: 0, y: 0, width: 1024, height: 768), display: true)
            window.center()
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
        self.windowWillClose?(self.website)
    }
}

#endif
