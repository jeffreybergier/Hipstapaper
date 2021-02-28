//
//  Created by Jeffrey Bergier on 2020/11/23.
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


import SwiftUI
import Umbrella
import Datum
import Stylize
import Localize

@main
struct HipstapaperApp: App {
    
    let controller: Controller?
    let watcher: DropboxWatcher?
    @StateObject private var windowPresentation = WindowPresentation()
    @State private var initializeError: IdentBox<UserFacingError>?
    
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
            self.controller = controller
            self.watcher = DropboxWatcher(controller: controller, errorQ: errorQ)
        case .failure(let error):
            errorQ.queue.append(error)
            log.error(error)
            _initializeError = .init(initialValue: .init(error))
            self.controller = nil
            self.watcher = nil
        }
    }

    @SceneBuilder var body: some Scene {
        WindowGroup(Noun.readingList.rawValue, id: "MainWindow", content: self.build)
    }
    
    @ViewBuilder private func build() -> some View {
        if let controller = self.controller {
            Main(controller: controller)
                .environmentObject(self.windowPresentation)
        } else {
            Color.clear
                .alert(item: self.$initializeError, content: { Alert($0.value) })
        }
    }
}
