//
//  Created by Jeffrey Bergier on 2020/12/20.
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

struct AddTag: View {
    
    @State private var tagName: String = ""
    let cancel: Modal.Action
    let save: (String?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            TextField.TagName(self.$tagName)
                .paddingDefault_Equal()
                .modifier(Modal.SaveCancel(title: Noun.AddTag,
                                           cancel: self.cancel,
                                           save: { self.save(self.tagName.nonEmptyString) }))
                .frame(width: 250, height: 150) // TODO: Remove height when this is not broken
        }
    }
}