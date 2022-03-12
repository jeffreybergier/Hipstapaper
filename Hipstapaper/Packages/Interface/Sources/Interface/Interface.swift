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

public struct Interface: Scene {
    
    let controller: Controller?
    let watcher: DropboxWatcher?
    @StateObject private var windowPresentation = WindowPresentation()
    @StateObject private var dropBoxWatcherErrorQ: ErrorQueue
    
    /*
    init() {
        let controller = P_Controller()
        self.controller = controller
        self.watcher = nil
    }
    */
    
    public init() {
        let errorQ = ErrorQueue()
        let result = ControllerNew()
        switch result {
        case .success(let controller):
            _dropBoxWatcherErrorQ = .init(wrappedValue: errorQ)
            self.controller = controller
            self.watcher = DropboxWatcher(controller: controller, errorQ: errorQ)
        case .failure(let error):
            log.error(error)
            errorQ.queue.append(error)
            _dropBoxWatcherErrorQ = .init(wrappedValue: errorQ)
            self.controller = nil
            self.watcher = nil
        }
    }

    @SceneBuilder public var body: some Scene {
        WindowGroup(Noun.readingList.rawValue, id: "MainWindow") {
            self.build()
                .alert(item: self.$dropBoxWatcherErrorQ.current) {
                    Alert($0.value)
                }
        }
    }
    
    @ViewBuilder private func build() -> some View {
        if let controller = self.controller {
            Root(controller: controller)
                .environmentObject(self.windowPresentation)
        } else {
            Color.clear
        }
    }
}
