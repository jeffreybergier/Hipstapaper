//
//  Created by Jeffrey Bergier on 2022/06/28.
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
import V3Localize
import V3Style

public struct ErrorList<ES: RandomAccessCollection & RangeReplaceableCollection>: View
                        where ES.Element == CodableError
{
    
    @Binding private var isError: CodableError?
    @Binding private var errorStorage: ES
    
    @Controller private var controller
    @V3Style.ErrorList private var style
    @V3Localize.ErrorList private var text
    
    @Environment(\.dismiss) private var dismiss
    
    public init(isError: Binding<CodableError?>, errorStorage: Binding<ES>) {
        _isError = isError
        _errorStorage = errorStorage
    }
        
    public var body: some View {
        NavigationStack {
            List(self.errorStorage,
                 id: \.self,
                 selection: self.$isError,
                 rowContent: ErrorListRow.init)
            .listStyle(.plain)
            .animation(.default, value: self.errorStorage.count)
            .modifier(self.toolbar)
            .modifier(self.alert)
        }
        .modifier(self.style.popoverSize)
    }
    
    private var toolbar: some ViewModifier {
        JSBToolbar(title: self.text.title,
                   done: self.text.done,
                   delete: self.text.clearAll)
        {
            self.dismiss()
        } deleteAction: {
            self.errorStorage.removeAll(where: { _ in true })
            self.dismiss()
        }
    }
    
    private var alert: some ViewModifier {
        UserFacingErrorAlert<LocalizeBundle, CodableError>(self.$isError) { error in
            guard let index = self.errorStorage.firstIndex(where: { $0.id == error.id }) else { return }
            self.errorStorage.remove(at: index)
        } transform: {
            $0.userFacingError {
                guard let error = perform(confirmation: $0, controller: self.controller) else { return }
                self.isError = error
            }
        }
    }
}

internal struct ErrorListRow: View {
    
    @V3Style.ErrorList private var style
    @V3Localize.ErrorListRow private var text: V3Localize.ErrorListRow.Value
    
    private let originalError: CodableError
    
    internal init(_ error: CodableError) {
        self.originalError = error
        _text = V3Localize.ErrorListRow(error.userFacingError())
    }
    
    internal var body: some View {
        self.style.error(title:   self.text.title,
                         message: self.text.message,
                         domain:  self.originalError.errorDomain,
                         code:    self.originalError.errorCode)
    }
}
