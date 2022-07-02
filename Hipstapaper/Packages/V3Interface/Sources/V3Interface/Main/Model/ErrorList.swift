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

internal struct ErrorList: View {
    
    @Nav private var nav
    @V3Localize.ErrorList private var text
    @Environment(\.dismiss) private var dismiss
        
    internal var body: some View {
        NavigationStack {
            VStack {
                List(self.nav.errorQueue,
                     id: \.self,
                     selection: self.$nav.detail.isErrorList.isError,
                     rowContent: ErrorListRow.init)
                .listStyle(.plain)
            }
            .animation(.default, value: self.nav.errorQueue)
            .modifier(self.toolbar)
            .modifier(self.alert)
        }
        .frame(idealWidth: 320, minHeight: 320)
    }
    
    private var toolbar: some ViewModifier {
        JSBToolbar(title: self.text.title,
                   done: self.text.done,
                   delete: self.text.clearAll)
        {
            self.dismiss()
        } deleteAction: {
            self.nav.errorQueue = []
            self.dismiss()
        }
    }
    
    private var alert: some ViewModifier {
        UserFacingErrorAlert<LocalizeBundle, CodableError>(self.$nav.detail.isErrorList.isError) {
            self.nav.delete(error: $0)
        } transform: {
            $0.userFacingError
        }
    }
}

internal struct ErrorListRow: View {
    
    @V3Localize.ErrorList private var text
    
    private let error: UserFacingError
    
    internal init(_ error: CodableError) {
        self.error = error.userFacingError
    }
    
    // TODO: Improve appearance
    internal var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(_text.key(self.error.title))
                Text(_text.key(self.error.message))
            }
            Spacer()
            Text(String(describing: error.errorCode))
        }
    }
}

internal struct ErrorListPresentation: ViewModifier {
    @Nav private var nav
    internal func body(content: Content) -> some View {
        content.popover(isPresented: self.$nav.detail.isErrorList.isPresented) {
            ErrorList()
        }
    }
}

extension ViewModifier {
    internal static var errorListPresentation: ErrorListPresentation { .init() }
}
