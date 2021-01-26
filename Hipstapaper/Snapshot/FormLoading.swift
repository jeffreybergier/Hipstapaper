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

struct FormLoading: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            STZ.VIEW.TXTFLD.WebTitle.textfield(self.$viewModel.output.title)
                .disabled(true)
            STZ.VIEW.TXTFLD.WebURL.textfield(self.$viewModel.output.currentURLString)
                .disabled(true)
            STZ.PRG.Bar(self.viewModel.progress)
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
