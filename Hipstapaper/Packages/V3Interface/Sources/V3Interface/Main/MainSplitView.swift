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
import V3Style
import V3Localize
import V3Errors
import V3Browser

internal struct MainSplitView: View {
    
    @Navigation private var nav
    @Controller private var controller
    @V3Style.MainMenu private var style
    @HACK_EditMode private var isEditMode
    @Localize private var bundle
    
    @Environment(\.errorResponder) private var errorResponder
    
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
        .modifier(self.style.syncIndicator(self.controller.syncProgress.progress))
        .onReceive(self.controller.syncProgress.objectWillChange) { _ in
            DispatchQueue.main.async {
                let errors = self.controller.syncProgress.errors
                guard errors.isEmpty == false else { return }
                self.controller.syncProgress.errors.removeAll()
                errors.forEach(self.errorResponder)
            }
        }
        .modifier(ErrorMover(isPresenting: self.nav.isPresenting,
                             toPresent: self.$nav.isError))
        .modifier(ErrorPresenter(isError: self.$nav.isError,
                                 localizeBundle: self.bundle,
                                 router: self.router(_:)))
    }
    
    
    private func router(_ input: CodableError) -> UserFacingError {
        ErrorRouter.route(input: input,
                          onSuccess: { },
                          onError: self.errorResponder,
                          controller: self.controller)
    }
}
