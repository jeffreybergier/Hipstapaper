//
//  Created by Jeffrey Bergier on 2020/12/05.
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
import Combine
import Stylize
import Localize
import Collections

public struct Snapshotter: View {
    
    @StateObject var viewModel: ViewModel
    @ErrorQueue private var errorQ
    
    public init(_ viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FormSwitcher(viewModel: self.viewModel)
                    .modifier(STZ.PDG.Equal(ignore: [\.bottom]))
                ZStack(alignment: .top) {
                    WebView(viewModel: self.viewModel)
                    WebThumbnail(viewModel: self.viewModel)
                        .modifier(STZ.PRG.BarMod(progress: self.viewModel.progress,
                                                 isVisible: self.viewModel.isLoading))
                }
                .frame(width: 300, height: 300)
                .modifier(STZ.CRN.Medium.apply())
                .modifier(STZ.PDG.Equal(ignore: [\.top]))
            }
        }
        .modifier(STZ.MDL.Save(
            kind: STZ.TB.AddWebsite.self,
            cancel: { self.viewModel.doneAction(.failure(.userCancelled)) },
            save: { self.viewModel.doneAction(.success(self.viewModel.output)) },
            canSave: { self.viewModel.output.currentURL != nil }
        ))
        .modifier(ErrorPresentation(self.$errorQ))
    }
}

internal struct WebThumbnail: View {
    @ObservedObject var viewModel: ViewModel
    @ViewBuilder var body: some View {
        if self.viewModel.formState == .load {
            STZ.ICN.web.thumbnail(self.viewModel.output.thumbnail?.value)
        } else {
            STZ.ICN.cloudError.thumbnail(self.viewModel.output.thumbnail?.value)
        }
    }
}
