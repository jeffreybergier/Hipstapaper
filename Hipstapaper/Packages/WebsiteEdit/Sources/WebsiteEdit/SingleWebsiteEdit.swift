//
//  Created by Jeffrey Bergier on 2022/04/08.
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
import Localize
import Stylize

internal struct SingleWebsiteEdit: View {
    
    @WebsiteEditQuery private var website: Website
    private let onDone: Action
    
    @ErrorQueue private var errorQ
    @StateObject private var control = Control()
    
    internal init(_ ident: Website.Ident, onDone: @escaping Action) {
        _website = .init(id: ident)
        self.onDone = onDone
    }
    
    internal var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                AutoloadForm(website: self.$website, control: self.control)
                    .modifier(STZ.PDG.Equal(ignore: [\.bottom]))
                Picture(website: self.$website, control: self.control)
                    .frame(width: 300, height: 300)
                    .modifier(STZ.CRN.Medium.apply())
                    .modifier(STZ.PDG.Equal(ignore: [\.top]))
            }
        }
        .modifier(STZ.MDL.Done(kind: STZ.TB.AddWebsite.self, done: self.onDone))
        .modifier(ErrorPresentation(self.$errorQ))
    }
}