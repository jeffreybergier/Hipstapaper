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

public protocol TextFieldable {
    associatedtype Style: TextFieldStyle
    static var style: Style { get }
    static var placeholder: LocalizedStringKey { get }
    static var autocorrection: Bool { get }
    #if canImport(UIKit)
    static var keyboard: UIKeyboardType { get }
    #endif
}

extension TextFieldable {
    #if os(macOS)
    public static func textfield(_ binding: Binding<String>) -> some View {
        TextField(self.placeholder, text: binding)
            .textFieldStyle(self.style)
            .disableAutocorrection(!self.autocorrection)
    }
    #else
    public static func textfield(_ binding: Binding<String>) -> some View {
        TextField(self.placeholder, text: binding)
            .textFieldStyle(self.style)
            .disableAutocorrection(!self.autocorrection)
            .keyboardType(self.keyboard)
    }
    #endif
}

extension STZ.VIEW {
    public enum TXTFLD {
        public enum WebURL: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder = Noun.WebsiteURL
            public static var autocorrection = false
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .URL
            #endif
        }
        public enum WebTitle: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder = Noun.WebsiteTitle
            public static var autocorrection = true
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .default
            #endif
        }
        public enum Search: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder = Noun.Search
            public static var autocorrection = true
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .default
            #endif
        }
        public enum TagName: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder = Noun.TagName
            public static var autocorrection = true
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .default
            #endif
        }
    }
}
