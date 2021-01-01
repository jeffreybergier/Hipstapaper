//
//  Created by Jeffrey Bergier on 2020/12/06.
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

enum Form {
    
    typealias Completion = (Result<Void, Error>) -> Void
    case load, loading, loaded
    
}

struct FormSwitcher: View {
    
    @ObservedObject var viewModel: Snapshotter.ViewModel
    
    var body: some View {
        Group {
            switch self.viewModel.formState {
            case .load:
                AnyView(FormLoad(input: self.$viewModel.input))
            case .loading:
                AnyView(FormLoading(output: self.viewModel.output))
            case .loaded:
                AnyView(FormLoaded(input: self.$viewModel.input, output: self.viewModel.output))
            }
        }
        .animation(.default)
    }
}
