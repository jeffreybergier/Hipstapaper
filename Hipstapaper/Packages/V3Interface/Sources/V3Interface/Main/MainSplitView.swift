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

internal struct MainSplitView: View {
    
    @Navigation   private var nav
    @ErrorStorage private var errors
    
    @V3Style.MainMenu private var style
    @HACK_EditMode    private var isEditMode
    
    @EnvironmentObject private var syncProgress: ContinousProgress.Environment
        
    internal var body: some View {
        NavigationSplitView {
            Sidebar()
        } detail: {
            Detail()
                .animation(.default, value: self.isEditMode)
                .editMode(force: self.isEditMode)
        }
        .modifier(BulkActionsHelper())
        .modifier(WebsiteEditSheet(self.$nav.isWebsitesEdit, start: .website))
        .modifier(self.style.syncIndicator(self.syncProgress.value.progress))
        .onChange(of: self.syncProgress.id, initial: true) { _, _ in
            let errors = self.syncProgress.value.errors
            guard errors.isEmpty == false else { return }
            self.syncProgress.value.errors = []
            errors.forEach(self.errors.append(_:))
        }
        .modifier(
            ErrorStorage.Presenter(
                isAlreadyPresenting: self.nav.isPresenting,
                toPresent: self.$nav.isError,
                router: errorRouter(_:)
            )
        )
    }
}

#if os(macOS)
// TODO: Giant Hack to allow MainMenu state to be separate
// from the scene. If Menus worked as expected, this would
// not be needed. Also has logic to sync the Scene state
// and the MainMenu state. Also, tries to disable logic if
// window is not frontmost.
internal struct HACK_MainSplitViewStateWrapper: View {
    
    @StateObject private var sceneState = BulkActions.newEnvironment()
    @EnvironmentObject private var mainMenuState: BulkActions.Environment
    
    @Environment(\.controlActiveState) private var active
    
    internal init() { }
    
    internal var body: some View {
        MainSplitView()
            .environmentObject(self.sceneState)
            .onChange(of: self.active) { _ in
                self.mainMenuState.value.pull = .init()
            }
            .onChange(of: self.sceneState.value.pull) {
                guard self.active == .key else { return }
                self.mainMenuState.value.pull = $0
            }
            .onChange(of: self.mainMenuState.value.push) {
                guard self.active == .key else { return }
                self.sceneState.value.push = $0
                self.mainMenuState.value.push = .init()
            }
    }
}
#else
internal struct HACK_MainSplitViewStateWrapper: View {
    
    internal init() { }
    
    internal var body: some View {
        MainSplitView()
    }
}
#endif

// TODO: HACK is needed because NavigationStack breaks toolbars on macOS
internal struct HACK_NavigationStack<V: View>: View {
    
    private let contents: () -> V
    
    internal init(contents: @escaping () -> V) {
        self.contents = contents
    }
    
    internal var body: some View {
        #if os(macOS)
        contents()
        #else
        NavigationStack {
            contents()
        }
        #endif
    }
}
