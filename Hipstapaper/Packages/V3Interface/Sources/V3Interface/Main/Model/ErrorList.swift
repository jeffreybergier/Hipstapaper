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

internal struct ErrorList: View {
    
    @Nav private var nav
    @Environment(\.dismiss) private var dismiss
        
    internal var body: some View {
        NavigationStack {
            VStack {
                List(self.nav.errorQueue, id: \.self, selection: self.$nav.detail.isErrorList.isError) { error in
                    HStack{
                        // TODO: Convert to UserFacingError
                        // to enhance display
                        Text(error.errorDomain)
                        Spacer()
                        Text("\(error.errorCode)")
                    }
                }
                .listStyle(.plain)
            }
            .sheet(item: self.$nav.detail.isErrorList.isError) { error in
                HStack{
                    // TODO: Convert to UserFacingError
                    // to show alert
                    Text(error.errorDomain)
                    Spacer()
                    Text("\(error.errorCode)")
                }
            }
            .modifier(self.toolbar)
        }
        .frame(idealWidth: 320, minHeight: 320)
    }
    
    private var toolbar: DoneToolbar {
        DoneToolbar(title: "Errors", done: "Done", delete: "Clear All") {
            self.dismiss()
        } deleteAction: {
            self.nav.errorQueue = []
            self.dismiss()
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
