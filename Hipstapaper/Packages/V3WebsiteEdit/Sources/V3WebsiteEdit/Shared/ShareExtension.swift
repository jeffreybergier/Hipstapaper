//
//  Created by Jeffrey Bergier on 2022/07/24.
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
import V3Model
import V3Store
import V3Localize

public struct ShareExtension: View {
    
    @StateObject private var localizeBundle = LocalizeBundle()
    @StateObject private var controller = Controller.newEnvironment()
    
    @State private var selection: Website.Selection = []
    private let inputURL: URL?
    private let onDismiss: () -> Void
    
    public init(inputURL: URL?, onDismiss: @escaping () -> Void) {
        self.inputURL = inputURL
        self.onDismiss = onDismiss
    }
    
    @ViewBuilder public var body: some View {
        self.selection.view { selection in
            switch self.controller.value {
            case .success(let controller):
                WebsiteEdit(selection: selection, start: .website)
                    .environmentObject(self.controller)
                    .environmentObject(self.localizeBundle)
                    .environment(\.closure, self.onDismiss)
                    .environment(\.managedObjectContext, controller.context)
            case .failure(let error):
                Text(String(describing: error))
            }
        } onEmpty: {
            Text("Loading...") // TODO: Improve this
                .task { DispatchQueue.main.async {
                    guard let controller = self.controller.value.value else { return }
                    switch controller.createWebsite(originalURL: self.inputURL) {
                    case .success(let identifier):
                        self.selection = [identifier]
                    case .failure(let error):
                        // TODO: Figure out how to get this error into the app
                        NSLog(String(describing: error))
                        assertionFailure(String(describing: error))
                    }
                }}
        }
    }
}
