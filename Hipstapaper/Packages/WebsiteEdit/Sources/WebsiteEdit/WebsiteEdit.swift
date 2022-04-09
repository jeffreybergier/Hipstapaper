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

public struct WebsiteEdit: View {
    
    @State private var control = Control()
    @WebsiteEditQuery private var website: Website
    @ErrorQueue private var errorQ
    
    public init(_ ident: Website.Ident) {
        _website = .init(id: ident)
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Form(website: self.$website, control: self.$control)
                    .modifier(STZ.PDG.Equal(ignore: [\.bottom]))
                ZStack(alignment: .top) {
                    Picture(website: self.$website, control: self.$control)
//                    WebView(viewModel: self.viewModel)
//                    WebThumbnail(viewModel: self.viewModel)
//                        .modifier(STZ.PRG.BarMod(progress: self.viewModel.progress,
//                                                 isVisible: self.viewModel.isLoading))
                }
                .frame(width: 300, height: 300)
                .modifier(STZ.CRN.Medium.apply())
                .modifier(STZ.PDG.Equal(ignore: [\.top]))
            }
        }
        .modifier(STZ.MDL.Save(
            kind: STZ.TB.AddWebsite.self,
            cancel: { /* TODO: FIX */ },
            save: { /* TODO: FIX */ },
            canSave: { true }
        ))
        .modifier(ErrorPresentation(self.$errorQ))
    }
}
