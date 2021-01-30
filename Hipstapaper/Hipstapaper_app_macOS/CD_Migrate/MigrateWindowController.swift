//
//  Created by Jeffrey Bergier on 2021/01/30.
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

import Cocoa
import Common

class MigrateWindowController: NSWindowController {
    
    class func new(controller: RealmController) -> NSWindowController {
        let wc = MigrateWindowController(windowNibName: "MigrateWindowController")
        wc.rc = controller
        return wc
    }
    
    private var rc: RealmController!
    private lazy var controller = CD_Controller(controller: self.rc, progress: self.progress)
    
    // progress hooked up with bindings
    @objc private let progress = Progress()
    @IBOutlet private weak var progressView: NSProgressIndicator!
    @IBOutlet private weak var startButton: NSButton!

    override func windowDidLoad() {
        super.windowDidLoad()
        _ = self.controller
    }
    
    @IBAction private func start(_ sender: NSButton) {
        sender.isEnabled = false
        self.controller.start() {
            print("Completed: \($0)")
        }
    }
    
}
