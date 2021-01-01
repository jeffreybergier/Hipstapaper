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
    
    @Binding var input: WebView.Input
    @ObservedObject var output: WebView.Output
    
    var body: some View {
        VStack {
            TextField.WebsiteTitle(self.$output.title)
            HStack {
                TextField.WebsiteURL(self.$output.resolvedURLString)
                    .disabled(true)
                if self.input.javascriptEnabled {
                    // TODO: Add Localized Strings Here
                    ButtonDefault("Disable JS") {
                        self.input.javascriptEnabled = false
                    }
                } else {
                    // TODO: Add Localized Strings Here
                    ButtonDefault("Enable JS") {
                        self.input.javascriptEnabled = true
                    }
                }
            }
        }
    }
}


#if DEBUG
struct FormLoaded_Preview: PreviewProvider {
    @State static var input = WebView.Input()
    static var output = WebView.Output()
    static var previews: some View {
        FormLoaded(input: self.$input, output: self.output)
            .previewLayout(.fixed(width: 300, height: 100.0))
    }
}
#endif
