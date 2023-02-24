//
//  Created by Jeffrey Bergier on 2022/06/29.
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

public enum UnknownErrorKeys {
    public static let title: LocalizationKey        = Noun.error.rawValue
    public static let message: LocalizationKey      = Phrase.errorUnknown.rawValue
    public static let dismissTitle: LocalizationKey = Verb.dismiss.rawValue
}

@propertyWrapper
public struct ErrorList: DynamicProperty {
    
    public struct Value {
        public var title:    LocalizedString
        public var done:     ActionLocalization
        public var clearAll: ActionLocalization
        public var ufe:      (UserFacingError, KeyPath<UserFacingError, LocalizationKey>) -> LocalizedString
        
        private let bundle: Bundle
        public func localize(_ input: UserFacingError) -> LocalizedUserFacingError {
            .init(b: self.bundle, e: input)
        }
        
        internal init(_ b: Bundle) {
            self.bundle = b
            self.title    = b.localized(key: Noun.errors.rawValue)
            self.done     = Action.doneGeneric.localized(b)
            self.clearAll = Action.deleteAllGeneric.localized(b)
            self.ufe      = { b.localized(key: $0[keyPath: $1]) }
        }
    }
    
    public struct LocalizedUserFacingError {
        
        public var title: LocalizedString
        public var message: LocalizedString
        
        internal init(b: Bundle, e: UserFacingError) {
            self.title = b.localized(key: e.title)
            self.message = b.localized(key: e.message)
        }
    }
    
    @Environment(\.bundle) private var bundle

    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
