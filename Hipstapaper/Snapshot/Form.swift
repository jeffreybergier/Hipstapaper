//
//  Created by Jeffrey Bergier on 2020/12/06.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
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

enum Form {
    
    typealias Completion = (Result<Void, Error>) -> Void
    case load, loading, loaded
    
}

struct FormSwitcher: View {
    
    @ObservedObject var viewModel: ViewModel
    
    @ViewBuilder var body: some View {
        Group {
            switch self.viewModel.formState {
            case .load:
                FormLoad(viewModel: self.viewModel)
            case .loading:
                FormLoading(viewModel: self.viewModel)
            case .loaded:
                FormLoaded(viewModel: self.viewModel)
            }
        }
        .animation(.default)
    }
}
