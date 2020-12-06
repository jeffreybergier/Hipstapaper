//
//  Created by Jeffrey Bergier on 2020/12/05.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI

public struct Snapshotter: View {
    
    class ViewModel: ObservableObject {
        @Published var input = WebView.Input()
        @Published var output = WebView.Output()
        var formState: Form.Which {
            switch (self.input.shouldLoad, self.output.isLoading) {
            case (false, _):
                return .load
            case (true, true):
                return .loading
            case (true, false):
                return .loaded
            }
        }
    }
    
    @ObservedObject var viewModel = ViewModel()
    
    public init() { }
    public var body: some View {
        VStack {
            Form(viewModel: self.viewModel)
                .padding()
            ZStack {
                WebView(input: self.$viewModel.input,
                        output: self.viewModel.output)
                switch self.viewModel.formState {
                case .load:
                    Image(systemName: "globe")
                case .loading:
                    // show nothing
                    Spacer().hidden()
                case .loaded:
                    Thumbnail(self.$viewModel.output.thumbnail)
                }
            }
            .frame(width: 300, height: 300)
        }
    }
}
