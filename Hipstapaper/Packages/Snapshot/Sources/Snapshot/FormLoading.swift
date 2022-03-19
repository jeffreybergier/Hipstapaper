//
//  Created by Jeffrey Bergier on 2020/12/06.
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
import Localize
import Stylize

struct FormLoading: View {
    
    @Localize private var text
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            STZ.VIEW.TXTFLD.WebTitle.textfield(self.$viewModel.output.title,
                                               bundle: self.text)
                .disabled(true)
            STZ.VIEW.TXTFLD.WebURL.textfield(self.$viewModel.output.currentURLString,
                                             bundle: self.text)
                .disabled(true)
        }
    }
}


#if DEBUG
struct FormLoading_Preview: PreviewProvider {
    static var viewModel = ViewModel(prepopulatedURL: nil, doneAction: { _ in })
    static var previews: some View {
        FormLoading(viewModel: viewModel)
            .previewLayout(.fixed(width: 300, height: 200.0))
    }
}
struct FormLoading_Preview2: PreviewProvider {
    static var viewModel: ViewModel = {
        let vm = ViewModel(prepopulatedURL: nil, doneAction: { _ in })
        vm.progress.completedUnitCount = 30
        vm.output.title = "Apple.com"
        vm.output.currentURL = URL(string: "https://www.google.com")!
        return vm
    }()
    static var previews: some View {
        FormLoading(viewModel: viewModel)
            .previewLayout(.fixed(width: 300, height: 200.0))
    }
}
#endif
