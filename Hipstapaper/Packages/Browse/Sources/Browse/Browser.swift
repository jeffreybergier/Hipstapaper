//
//  Created by Jeffrey Bergier on 2020/12/20.
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
import Stylize
import Collections
import Localize

public struct Browser: View {
    
    @StateObject public var viewModel: ViewModel
    @ErrorQueue private var errorQ

    public var body: some View {
        ZStack(alignment: .top) {
            WebView(viewModel: self.viewModel)
                .frame(minWidth: 300, idealWidth: 768, minHeight: 300, idealHeight: 768)
                .edgesIgnoringSafeArea(.all)
            Color.clear // needed so the progress bar doesn't also ignore safe areas
                .modifier(STZ.PRG.BarMod(progress: self.viewModel.browserDisplay.progress,
                                         isVisible: self.viewModel.browserDisplay.isLoading))
        }
        .onAppear() {
            guard self.viewModel.originalURL == nil else { return }
            // self.errorQ.queue.append(Error.loadURL)
        }
        // TODO: Toolbar leaks like crazy on iOS :(
        .modifier(Toolbar(viewModel: self.viewModel))
        .modifier(ErrorPresentation(self.$errorQ.first))
    }
    
    public init(_ viewModel: ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    public init(url: URL?, doneAction: (() -> Void)?) {
        _viewModel = .init(wrappedValue: .init(url: url, doneAction: doneAction))
    }
}
