//
//  Created by Jeffrey Bergier on 2020/11/23.
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
import XCGLogger
import Datum
import Browse

internal let log: XCGLogger = {
    XCGLogger(identifier: "Hipstapaper.App.Logger", includeDefaultDestinations: true)
}()

@main
struct HipstapaperApp: App {

    @StateObject var controller: AnyUIController
    
    init() {
        let controller = try! ControllerNew()
        _controller = StateObject(wrappedValue: P_UIController.new())
    }

    @SceneBuilder var body: some Scene {
        WindowGroup {
            Main(controller: self.controller)
        }
        #if os(macOS)
        Settings {
            Browse(URL(string: "https://www.theverge.com")!)
        }
        #endif
    }
}
