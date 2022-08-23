//
//  Created by Jeffrey Bergier on 2022/06/17.
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
import V3Store
import V3Style
import V3Localize
import V3Errors
import V3WebsiteEdit

public struct MainWindow: Scene {
    
    @StateObject private var localizeBundle = LocalizeBundle()
    @StateObject private var controller = Controller.newEnvironment()
    @StateObject private var mainMenuState = BulkActions.newEnvironment()
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            switch self.controller.value {
            case .success(let controller):
                MainView()
                    .environmentObject(self.controller)
                    .environmentObject(self.localizeBundle)
                    .environmentObject(self.mainMenuState)
                    .environment(\.managedObjectContext, controller.context)
            case .failure(let error):
                Text(String(describing: error))
            }
        }
        .commands {
            MainMenu(state: self.mainMenuState,
                     controller: self.controller,
                     bundle: self.localizeBundle)
        }
    }
}

internal struct MainView: View {
    
    @Navigation private var nav
    @Selection private var selection
    @Errors private var errorQueue
    @Controller private var controller
    @V3Style.MainMenu private var style
    
    internal var body: some View {
        ErrorResponder(presenter: self.$nav, storage: self.$errorQueue) {
            NavigationSplitView {
                Sidebar()
            } detail: {
                Detail()
                    .editMode(force: true)
                    // Force editMode on the detail table
                    // TODO: Find better way to create a
                    // Modal NavigationLink for websites
            }
            .modifier(BulkActionsHelper())
            .modifier(WebsiteEditSheet(self.$nav.isWebsitesEdit, start: .website))
            .modifier(self.style.syncIndicator(self.controller.syncProgress.progress))
            .onReceive(self.controller.syncProgress.objectWillChange) { _ in
                DispatchQueue.main.async {
                    let errors = self.controller.syncProgress.errors.map { $0.codableValue }
                    guard errors.isEmpty == false else { return }
                    self.controller.syncProgress.errors.removeAll()
                    self.errorQueue.append(contentsOf: errors)
                }
            }
        } onConfirmation: {
            switch $0 {
            case .deleteWebsites(let deleted):
                self.selection.websites.subtract(deleted)
            case .deleteTags(let deleted):
                guard deleted.contains(self.selection.tag ?? .default) else { return }
                self.selection.tag = .default
            }
        }
    }
}
