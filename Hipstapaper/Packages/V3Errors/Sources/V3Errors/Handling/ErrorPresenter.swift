//
//  Created by Jeffrey Bergier on 2022/11/20.
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

public struct ErrorPresenter: ViewModifier {
    
    private let bundle: any EnvironmentBundleProtocol
    private let router: (Error) -> any UserFacingError
    private let onDismiss: (Error) -> Void
    
    @Binding private var isError: ErrorStorage.Identifier?
    @ErrorStorage private var storage
    
    public init(isError: Binding<ErrorStorage.Identifier?>,
                localizeBundle: any EnvironmentBundleProtocol,
                router: @escaping (Error) -> any UserFacingError,
                onDismiss: @escaping (Error) -> Void = { _ in })
    {
        _isError = isError
        self.bundle = localizeBundle
        self.router = router
        self.onDismiss = onDismiss
    }
    
    public func body(content: Content) -> some View {
        content
            .alert(anyError: self.isUserFacingError,
                   bundle:   self.bundle,
                   onDismiss: { self.onDismiss($0) })
    }
    
    private var isUserFacingError: Binding<UserFacingError?> {
        Binding {
            guard
                let identifier = self.isError,
                let error = _storage.pop(identifier)
            else { return nil }
            return self.router(error)
        } set: {
            guard $0 == nil else { return }
            self.isError = nil
        }
    }
}
