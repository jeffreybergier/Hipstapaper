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
        
        public var back:         ActionLocalization
        public var forward:      ActionLocalization
        public var stop:         ActionLocalization
        public var reload:       ActionLocalization
        public var jsYes:        ActionLocalization
        public var jsNo:         ActionLocalization
        public var openExternal: ActionLocalization
        public var archiveYes:   ActionLocalization
        public var share:        ActionLocalization
        public var done:         ActionLocalization
        public var loading:      LocalizedString
        
        internal init(_ b: Bundle) {
            self.back         = Action.browseBack.localized(b)
            self.forward      = Action.browseForward.localized(b)
            self.stop         = Action.browseStop.localized(b)
            self.reload       = Action.browseReload.localized(b)
            self.jsYes        = Action.javascriptYes.localized(b)
            self.jsNo         = Action.javascriptNo.localized(b)
            self.openExternal = Action.openExternal.localized(b)
            self.archiveYes   = Action.archiveYes.localized(b)
            self.share        = Action.share.localized(b)
            self.done         = Action.doneGeneric.localized(b)
            self.loading      = b.localized(key: Phrase.loadingPage.rawValue)
        }
    }
    
    @Environment(\.bundle) private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
