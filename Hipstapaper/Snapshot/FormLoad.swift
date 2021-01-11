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
import Stylize

struct FormLoad: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        HStack() {
            TextField.WebsiteURL(self.$viewModel.output.inputURLString)
            STZ.BTN.Go.button(isDisabled: self.viewModel.output.inputURL == nil,
                              action: { self.viewModel.control.shouldLoad.toggle() })
        }
    }
}

#if DEBUG
struct FormLoad_Preview1: PreviewProvider {
    static var viewModel = ViewModel(prepopulatedURL: nil, doneAction: { _ in })
    static var previews: some View {
        FormLoad(viewModel: viewModel)
            .previewLayout(.fixed(width: 300, height: 100.0))
    }
}
struct FormLoad_Preview2: PreviewProvider {
    static let viewModel: ViewModel = {
        let vm = ViewModel(prepopulatedURL: nil,
                           doneAction: { _ in })
        vm.output.inputURLString = "https://www.google.com"
        return vm
    }()
    static var previews: some View {
        FormLoad(viewModel: viewModel)
            .previewLayout(.fixed(width: 300, height: 100.0))
    }
}
#endif
