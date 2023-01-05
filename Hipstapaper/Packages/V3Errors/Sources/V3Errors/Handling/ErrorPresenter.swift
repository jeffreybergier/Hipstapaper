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
    private let router: (CodableError) -> any UserFacingError
    private let onDismiss: (CodableError?) -> Void
    
    @Binding private var isError: CodableError?
    @Environment(\.errorResponder) private var errorResponder
    
    public init(isError: Binding<CodableError?>,
                localizeBundle: any EnvironmentBundleProtocol,
                router: @escaping (CodableError) -> any UserFacingError,
                onDismiss: @escaping (CodableError?) -> Void = { _ in })
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
                   onDismiss: { _ in self.onDismiss(self.isError) })
    }
    
    private var isUserFacingError: Binding<UserFacingError?> {
        Binding {
            guard let error = self.isError else { return nil }
            return self.router(error)
        } set: {
            guard $0 == nil else { return }
            self.isError = nil
        }
    }
}
