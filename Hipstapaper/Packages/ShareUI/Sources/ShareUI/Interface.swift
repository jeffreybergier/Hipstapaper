//
//  Created by Jeffrey Bergier on 2022/05/12.
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

public struct Interface: View {
        
    @StateObject private var controllerBox: BlackBox<Controller?>
    @StateObject private var errorEnvironment: ErrorQueue.Environment
    @StateObject private var localizationBundle = LocalizeBundle()
    @ObservedObject private var control: Control
    private let websiteIdent: Website.Ident?
    
    public init(control: Control) {
        let errorQ = ErrorQueue.newEnvirementObject()
        let result1 = ControllerNew()
        let result2 = result1.flatMap { $0.createWebsite(nil) }
        switch (result1, result2) {
        case (.success(let controller), .success(let ident)):
            _errorEnvironment = .init(wrappedValue: errorQ)
            _controllerBox = .init(wrappedValue: BlackBox(controller))
            self.websiteIdent = ident
        case (.failure(let error), _):
            fallthrough
        case (_, .failure(let error)):
            NSLog(String(describing: error))
            _errorEnvironment = .init(wrappedValue: errorQ)
            _controllerBox = .init(wrappedValue: BlackBox(nil))
            self.websiteIdent = nil
        }
        _control = .init(wrappedValue: control)
    }

    public var body: some View {
        self.build()
            .environmentObject(self.errorEnvironment)
            .environmentObject(self.localizationBundle)
            .environmentObject(self.control)
    }
    
    @ViewBuilder private func build() -> some View {
        if let controller = self.controllerBox.value, let ident = self.websiteIdent {
            Root(id: ident)
                .environmentObject(self.controllerBox)
                .environment(\.managedObjectContext, controller.ENVIRONMENTONLY_managedObjectContext)
        } else {
            Color.clear
        }
    }
}
