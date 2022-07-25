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
import V3Store
import V3Localize

public protocol ErrorPresentable {
    var isError: CodableError? { get set }
    var isPresenting: Bool { get }
}

public struct ErrorResponder<V: View, EP: ErrorPresentable, EC: RangeReplaceableCollection>: View where EC.Element == CodableError {
    
    @Binding private var errorStorage: EC
    @Binding private var errorPresentable: EP
    @Controller private var controller
    
    @Environment(\.codableErrorResponder) private var errorResponder
    
    private let content: () -> V
    private let onConfirmation: OnConfirmation
    
    public init(presenter: Binding<EP>,
                storage: Binding<EC>,
                @ViewBuilder content: @escaping () -> V,
                onConfirmation: @escaping OnConfirmation)
    {
        self.content = content
        self.onConfirmation = onConfirmation
        _errorPresentable = presenter
        _errorStorage = storage
    }
    
    public var body: some View {
        self.content()
            .environment(\.codableErrorResponder, self.handle(_:))
            .modifier(self.alert)
    }
    
    private func handle(_ error: CodableError) {
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
            self.errorStorage.append(error)
        }
    }
    
    private var alert: some ViewModifier {
        // TODO: Pass UserFacingError or Confirmation back up so UI can respond
        UserFacingErrorAlert<LocalizeBundle, CodableError>(self.$errorPresentable.isError) {
            $0.userFacingError {
                if let error = perform(confirmation: $0, controller: self.controller) {
                    self.handle(error)
                } else {
                    self.onConfirmation($0)
                }
            }
        }
    }
}
