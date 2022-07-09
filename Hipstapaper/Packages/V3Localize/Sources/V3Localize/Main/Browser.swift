//
//  Created by Jeffrey Bergier on 2022/07/02.
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
public struct Browser: DynamicProperty {

    public struct Value {
        public var back:         LocalizedString
        public var forward:      LocalizedString
        public var stop:         LocalizedString
        public var reload:       LocalizedString
        public var jsYes:        LocalizedString
        public var jsNo:         LocalizedString
        public var openExternal: LocalizedString
        public var archiveYes:   LocalizedString
        public var share:        LocalizedString
        public var done:         LocalizedString
        public var loading:      LocalizedString
        public var error:        LocalizedString
        
        internal init(_ b: LocalizeBundle) {
            self.back         = b.localized(key: Verb.goBack.rawValue)
            self.forward      = b.localized(key: Verb.goForward.rawValue)
            self.stop         = b.localized(key: Verb.stopLoading.rawValue)
            self.reload       = b.localized(key: Verb.reloadPage.rawValue)
            self.jsYes        = b.localized(key: Verb.javascriptYes.rawValue)
            self.jsNo         = b.localized(key: Verb.javascriptNo.rawValue)
            self.openExternal = b.localized(key: Verb.openExternal.rawValue)
            self.archiveYes   = b.localized(key: Verb.archiveClose.rawValue)
            self.share        = b.localized(key: Verb.share.rawValue)
            self.done         = b.localized(key: Verb.done.rawValue)
            self.loading      = b.localized(key: Phrase.loadingPage.rawValue)
            self.error        = b.localized(key: Verb.errorsPresent.rawValue)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
