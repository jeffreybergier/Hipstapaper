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
import Localize

struct FormLoad: View {
    
    @Binding var input: WebView.Input
    
    var body: some View {
        HStack() {
            TextField.WebsiteURL(self.$input.originalURLString)
            ButtonDone(Go) {
                self.input.shouldLoad.toggle()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(URL(string: self.input.originalURLString) == nil)
        }
    }
}

#if DEBUG
struct FormLoad_Preview: PreviewProvider {
    @State static var input = WebView.Input()
    static var previews: some View {
        FormLoad(input: self.$input)
            .previewLayout(.fixed(width: 300, height: 100.0))
    }
}
#endif
