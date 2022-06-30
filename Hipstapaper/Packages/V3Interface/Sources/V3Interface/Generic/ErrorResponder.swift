//
//  Created by Jeffrey Bergier on 2022/06/27.
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
import V3Localize

internal protocol ErrorPresentable {
    var isError: CodableError? { get set }
    var isPresenting: Bool { get }
}

internal struct ErrorResponder<V: View, EP: ErrorPresentable>: View {
    
    @Nav private var nav
    @Binding private var errorPresentable: EP
    @Environment(\.codableErrorResponder) private var errorChain
    
    private let content: () -> V
    
    internal init(_ binding: Binding<EP>,
                  @ViewBuilder content: @escaping () -> V)
    {
        self.content = content
        _errorPresentable = binding
    }
    
    internal var body: some View {
        self.content()
            .environment(\.codableErrorResponder) { error in
                if
                    self.errorPresentable.isError == nil,
                    self.errorPresentable.isPresenting == false
                {
                    self.errorPresentable.isError = error
                } else {
                    // Note to future self: Don't pass down the chain
                    // If this view can't respond to an error,
                    // no view down the chain can either.
                    // Just put it straight into the errorStorage
                    // self.errorChain(error)
                    self.nav.errorQueue.append(error)
                    print("Uncaught Errors: \(self.nav.errorQueue.count)") // TODO: Delete print statement
                }
            }
            .modifier(self.alert)
    }
    
    private var alert: some ViewModifier {
        UserFacingErrorAlert<LocalizeBundle, CodableError>(self.$errorPresentable.isError) {
            $0.userFacingError
        }
    }
}
