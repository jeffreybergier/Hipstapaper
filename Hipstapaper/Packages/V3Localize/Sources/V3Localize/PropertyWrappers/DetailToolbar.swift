//
//  Created by Jeffrey Bergier on 2022/06/19.
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
public struct DetailToolbar: DynamicProperty {
    
    public struct Value {
        public var openInApp:    ActionLocalization
        public var openExternal: ActionLocalization
        public var archiveYes:   ActionLocalization
        public var archiveNo:    ActionLocalization
        public var share:        ActionLocalization
        public var tagApply:     ActionLocalization
        public var edit:         ActionLocalization
        public var delete:       ActionLocalization
        public var error:        ActionLocalization
        public var deselectAll:  ActionLocalization
        
        internal init(_ b: LocalizeBundle) {
            self.openInApp    = .openInApp(b)
            self.openExternal = .openExternal(b)
            self.archiveYes   = .archiveYes(b)
            self.archiveNo    = .archiveNo(b)
            self.share        = .share(b)
            self.tagApply     = .tagApply(b)
            self.edit         = .editWebsite(b)
            self.delete       = .deleteWebsite(b)
            self.error        = .errorsPresent(b)
            self.deselectAll  = .deselectAll(b)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
