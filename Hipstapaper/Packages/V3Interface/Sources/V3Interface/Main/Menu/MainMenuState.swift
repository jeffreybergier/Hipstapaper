//
//  Created by Jeffrey Bergier on 2022/07/22.
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

@propertyWrapper
internal struct MainMenuState: DynamicProperty {
    
    internal typealias Environment = BlackBox<MainMenu.State>
    
    internal static func newEnvironment() -> Environment {
        .init(.init(), isObservingValue: true)
    }
    
    @EnvironmentObject private var environment: Environment
    
    internal var wrappedValue: MainMenu.State {
        get { self.environment.value }
        nonmutating set { self.environment.value = newValue }
    }
}

internal struct MainMenuStateHelper: ViewModifier {
    
    @Nav private var nav
    @MainMenuState private var state
    
    internal func body(content: Content) -> some View {
        content
            .onChange(of: self.nav) {
                self.state = .init(
                    selectedWebsites: $0.detail.selectedWebsites,
                    selectedTags: $0.sidebar.selectedTag.map { Set([$0]) } ?? [],
                    canShowErrors: !$0.errorQueue.isEmpty
                )
            }
    }
}
