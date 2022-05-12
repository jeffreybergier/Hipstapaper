//
//  Created by Jeffrey Bergier on 2020/12/11.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI
import Umbrella
import Localize

public protocol TextFieldable {
    associatedtype Style: TextFieldStyle
    static var style: Style { get }
    static var placeholder: Noun { get }
    static var autocorrection: Bool { get }
    #if canImport(UIKit)
    static var keyboard: UIKeyboardType { get }
    #endif
}

extension TextFieldable {
    #if os(macOS)
    public static func textfield(_ binding: Binding<String>,
                                 bundle: LocalizeBundle) -> some View
    {
        TextField(self.placeholder.loc(bundle), text: binding)
            .textFieldStyle(self.style)
            .disableAutocorrection(!self.autocorrection)
    }
    public static func textfield(_ binding: Binding<String?>,
                                 bundle: LocalizeBundle) -> some View
    {
        JSBTextField(self.placeholder.loc(bundle), text: binding)
            .textFieldStyle(self.style)
            .disableAutocorrection(!self.autocorrection)
    }
    public static func textfield(_ binding: Binding<URL?>,
                                 bundle: LocalizeBundle) -> some View
    {
        let map = binding.map(forward: { $0?.absoluteString },
                              reverse: { URL(string: $0 ?? "") })
        return JSBTextField(self.placeholder.loc(bundle), text: map)
            .textFieldStyle(self.style)
            .disableAutocorrection(!self.autocorrection)
    }
    #else
    public static func textfield(_ binding: Binding<String>,
                                 bundle: LocalizeBundle) -> some View
    {
        TextField(self.placeholder.loc(bundle), text: binding)
            .textFieldStyle(self.style)
            .disableAutocorrection(!self.autocorrection)
            .keyboardType(self.keyboard)
    }
    public static func textfield(_ binding: Binding<String?>,
                                 bundle: LocalizeBundle) -> some View
    {
        JSBTextField(self.placeholder.loc(bundle), text: binding)
            .textFieldStyle(self.style)
            .disableAutocorrection(!self.autocorrection)
            .keyboardType(self.keyboard)
    }
    public static func textfield(_ binding: Binding<URL?>,
                                 bundle: LocalizeBundle) -> some View
    {
        let map = binding.map(forward: { $0?.absoluteString },
                              reverse: { URL(string: $0 ?? "") })
        return JSBTextField(self.placeholder.loc(bundle), text: map)
            .textFieldStyle(self.style)
            .disableAutocorrection(!self.autocorrection)
            .keyboardType(self.keyboard)
    }
    #endif
}

extension STZ.VIEW {
    public enum TXTFLD {
        public enum OriginalURL: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder: Noun = .originalURL
            public static var autocorrection = false
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .URL
            #endif
        }
        public enum ResolvedURL: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder: Noun = .resolvedURL
            public static var autocorrection = false
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .URL
            #endif
        }
        public enum AutofillURL: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder: Noun = .autofillURL
            public static var autocorrection = false
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .URL
            #endif
        }
        public enum FilledURL: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder: Noun = .filledURL
            public static var autocorrection = false
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .URL
            #endif
        }
        public enum WebTitle: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder: Noun = .websiteTitle
            public static var autocorrection = true
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .default
            #endif
        }
        public enum Search: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder: Noun = .search
            public static var autocorrection = true
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .default
            #endif
        }
        public enum TagName: TextFieldable {
            public static var style = RoundedBorderTextFieldStyle()
            public static var placeholder: Noun = .tagName
            public static var autocorrection = true
            #if canImport(UIKit)
            public static var keyboard: UIKeyboardType = .default
            #endif
        }
    }
}
