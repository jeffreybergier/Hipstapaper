//
//  Created by Jeffrey Bergier on 2022/08/03.
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

@propertyWrapper
public struct ShareList: DynamicProperty {
    
    public struct Value {
        public var title: LocalizedString
        public var done: LocalizedString
        public var untitled: LocalizedString
        public var shareAll: LocalizedString
        public var shareError: LocalizedString
        public var itemsCount: (Int) -> LocalizedString
        
        internal init(_ b: LocalizeBundle) {
            self.title      = b.localized(key: Noun.share.rawValue)
            self.done       = b.localized(key: Verb.done.rawValue)
            self.untitled   = b.localized(key: Noun.untitled.rawValue)
            self.shareAll   = b.localized(key: Verb.shareAll.rawValue)
            self.shareError = b.localized(key: Phrase.shareError.rawValue)
            self.itemsCount = {
                // TODO: improve to use strings dict
                return String(describing: $0) + " " + "websites(s)"
            }
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
    
    public func key(_ input: LocalizationKey) -> LocalizedString {
        self.bundle.localized(key: input)
    }
}
