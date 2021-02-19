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
import Umbrella
import Datum
import Stylize

@main
struct HipstapaperApp: App {
    
    let controller: Controller?
    let watcher: DropboxWatcher?
    @StateObject private var windowPresentation = WindowPresentation()
    @StateObject private var errorQ: ErrorQueue
    
    /*
    init() {
        let errorQ = STZ.ERR.ViewModel()
        let controller = P_Controller()
        _errorQ = .init(wrappedValue: errorQ)
        self.controller = controller
        self.watcher = DropboxWatcher(controller: controller, errorQ: errorQ)
    }
    */
    
    init() {
        let errorQ = ErrorQueue()
        let result = ControllerNew()
        switch result {
        case .success(let controller):
            _errorQ = .init(wrappedValue: errorQ)
            self.controller = controller
            self.watcher = DropboxWatcher(controller: controller, errorQ: errorQ)
        case .failure(let error):
            errorQ.queue.append(error)
            log.error(error)
            _errorQ = .init(wrappedValue: errorQ)
            self.controller = nil
            self.watcher = nil
        }
    }

    @SceneBuilder var body: some Scene {
        // TODO: Localize Reading List
        WindowGroup("Reading List", id: "MainWindow", content: self.build)
    }
    
    @ViewBuilder private func build() -> some View {
        if let controller = self.controller {
            Main(controller: controller)
                .modifier(ErrorQueuePresenter())
                .environmentObject(self.windowPresentation)
                .environmentObject(self.errorQ)
        } else {
            Color.clear
                .modifier(ErrorQueuePresenter())
                .environmentObject(self.errorQ)
        }
    }
}
