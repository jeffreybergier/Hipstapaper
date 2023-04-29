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
import V3Model
import V3Store
import V3Localize
import V3Errors
import V3Browser
import V3Terminator

public struct SceneBootstrap: Scene {
    
    @StateObject private var controller     = Controller.newEnvironment()
    @StateObject private var mainMenuState  = BulkActions.newEnvironment()
    @Terminator  private var terminator
    
    private let bundle = LocalizeBundle
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            Group {
                switch self.controller.value {
                case .success(let controller):
                    HACK_MainSplitViewStateWrapper()
                        .environmentObject(self.controller)
                        .environmentObject(self.mainMenuState)
                        .environmentObject(controller.syncProgress)
                        .environment(\.bundle, self.bundle)
                        .environment(\.managedObjectContext, controller.context)
                case .failure(let error):
                    Text(String(describing: error))
                }
            }
            .onChange(of: self.terminator.shouldTerminateHostApplication) {
                switch $0 {
                case true:
                    self.controller.value = .failure(NSError(domain: "Extension Open", code: 1))
                case false:
                    self.controller.value = Controller.newEnvironment().value
                }
            }
        }
        .commands {
            MainMenu(state: self.mainMenuState,
                     controller: self.controller,
                     bundle: self.bundle)
        }
        WindowGroup(for: V3Model.Website.Identifier.self) { $value in
            switch (self.controller.value, value) {
            case (.success(let controller), .some(let identifier)):
                Browser(identifier)
                    .environmentObject(self.controller)
                    .environment(\.bundle, self.bundle)
                    .environment(\.managedObjectContext, controller.context)
            case (_, .none):
                // TODO: Localize
                Text("No Selection")
            case (.failure(let error), _):
                Text(String(describing: error))
            default:
                fatalError()
            }
        } // TODO: Add commands?
    }
}
