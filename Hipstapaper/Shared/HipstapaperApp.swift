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
import Stylize

internal let log: XCGLogger = {
    XCGLogger(identifier: "Hipstapaper.App.Logger", includeDefaultDestinations: true)
}()

protocol ErrorQ: class {
    func append(_ error: LocalizedError)
    @discardableResult
    func append<T, E: LocalizedError>(_ result: Result<T, E>) -> T?
}

extension STZ.ERR.ViewModel: ErrorQ {}

@main
struct HipstapaperApp: App {
    
    let controller: Controller?
    let watcher: DropboxWatcher?
    @StateObject private var modalPresentation = ModalPresentation.Wrap()
    @StateObject private var windowPresentation = WindowPresentation()
    @StateObject private var errorQ: STZ.ERR.ViewModel
    
    init() {
        let errorQ = STZ.ERR.ViewModel()
        guard let controller = errorQ.append(ControllerNew()) else {
            _errorQ = .init(wrappedValue: errorQ)
            self.controller = nil
            self.watcher = nil
            return
        }
        _errorQ = .init(wrappedValue: errorQ)
        
        // self.controller = P_Controller()
        self.controller = controller
        self.watcher = DropboxWatcher(controller: controller, errorQ: errorQ)
    }

    @SceneBuilder var body: some Scene {
        WindowGroup { () -> AnyView in
            if let controller = self.controller {
                return AnyView(
                    Main(controller: controller)
                        .environmentObject(self.windowPresentation)
                        .environmentObject(self.modalPresentation)
                        .environmentObject(self.errorQ)
                )
            } else {
                return AnyView(
                    Color.clear
                        .modifier(STZ.ERR.PresenterB())
                        .environmentObject(self.errorQ)
                )
            }
        }
    }
}
