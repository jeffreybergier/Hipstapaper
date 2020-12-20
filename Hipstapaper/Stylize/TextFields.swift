//
//  Created by Jeffrey Bergier on 2020/12/11.
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
import Localize

extension TextField where Label == Text {

    public static func WebsiteURL(_ binding: Binding<String>) -> some View {
        let tf = SwiftUI.TextField(Localize.WebsiteURL, text: binding)
            .disableAutocorrection(true)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        #if canImport(UIKit)
        return tf.keyboardType(.URL)
        #else
        return tf
        #endif
    }
    
    public static func WebsiteTitle(_ binding: Binding<String>) -> some View {
        return SwiftUI.TextField(Localize.WebsiteTitle, text: binding)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    public static func Search(_ binding: Binding<String>) -> some View {
        return SwiftUI.TextField(Localize.Search, text: binding)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    public static func TagName(_ binding: Binding<String>) -> some View {
        return SwiftUI.TextField(Localize.TagName, text: binding)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
