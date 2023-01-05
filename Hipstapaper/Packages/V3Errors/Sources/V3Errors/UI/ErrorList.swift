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
    
    @Localize   private var bundle
    @Controller private var controller
    @V3Style.ErrorList private var style
    @V3Localize.ErrorList private var text
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorResponder) private var errorResponder
    
    @State private var isError: CodableError?
    @Binding private var errorStorage: ES
    
    public init(errorStorage: Binding<ES>) {
        _errorStorage = errorStorage
    }
    
    public var body: some View {
        NavigationStack {
            List(self.errorStorage,
                 id: \.self,
                 selection: self.$isError)
            {
                ErrorListRow(self.router($0))
            }
            .listStyle(.plain)
            .animation(.default, value: self.errorStorage.count)
            .modifier(self.toolbar)
        }
        .modifier(self.style.popoverSize)
        .modifier(ErrorPresenter(isError: self.$isError,
                                 localizeBundle: self.bundle,
                                 router: self.router(_:),
                                 onDismiss: self.clear(_:)))
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
    
    private func clear(_ error: CodableError?) {
        guard let error else { return }
        self.errorStorage.removeAll { error == $0 }
    }
    
    private func router(_ input: CodableError) -> UserFacingError {
        ErrorRouter.route(input: input,
                          onSuccess: { },
                          onError: self.errorResponder,
                          controller: self.controller)
    }
}

internal struct ErrorListRow: View {
    
    @V3Style.ErrorList private var style
    @V3Localize.ErrorList private var text
        
    private let error: UserFacingError
    
    internal init(_ error: UserFacingError) {
        self.error = error
    }
    
    internal var body: some View {
        self.style.error(title:   self.text.localize(self.error).title,
                         message: self.text.localize(self.error).message,
                         domain:  type(of: self.error).errorDomain,
                         code:    self.error.errorCode)
    }
}
