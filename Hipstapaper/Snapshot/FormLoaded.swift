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

struct FormLoaded: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            TextField.WebsiteTitle(self.$viewModel.output.title)
            HStack {
                TextField.WebsiteURL(self.$viewModel.output.currentURLString)
                    .disabled(true)
                ButtonToolbarJavascript(self.$viewModel.control.isJSEnabled)
            }
        }
    }
}


#if DEBUG
struct FormLoaded_Preview: PreviewProvider {
    static var viewModel = ViewModel(prepopulatedURL: nil, doneAction: { _ in })
    static var previews: some View {
        FormLoaded(viewModel: viewModel)
            .previewLayout(.fixed(width: 300, height: 200.0))
    }
}
#endif
