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
import V3Localize
import V3Errors

public struct MainWindow: Scene {
    
    @StateObject private var localizeBundle = LocalizeBundle()
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(self.localizeBundle)
        }
    }
}

internal struct MainView: View {
    
    @Nav private var nav
    
    internal var body: some View {
        ErrorResponder(presenter: self.$nav, storage: self.$nav.errorQueue) {
            NavigationSplitView {
                Sidebar()
            } detail: {
                Detail()
                    // Force editMode on the detail table
                    // TODO: Find better way to create a
                    // Modal NavigationLink for websites
                    .editMode(force: true)
            }
        }
    }
}
