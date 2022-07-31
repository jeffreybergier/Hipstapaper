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
        public var openInApp:    LocalizedString
        public var openExternal: LocalizedString
        public var archiveYes:   LocalizedString
        public var archiveNo:    LocalizedString
        public var share:        LocalizedString
        public var tagApply:     LocalizedString
        public var edit:         LocalizedString
        public var delete:       LocalizedString
        public var sort:         LocalizedString
        public var error:        LocalizedString
        public var selectAll:    LocalizedString
        public var deselectAll:  LocalizedString
        public var itemsCount: (Int) -> LocalizedString
        public var itemSelectedTotal: (Int, Int) -> LocalizedString
        
        internal init(_ b: LocalizeBundle) {
            self.openInApp    = b.localized(key: Verb.openInApp.rawValue)
            self.openExternal = b.localized(key: Verb.openExternal.rawValue)
            self.archiveYes   = b.localized(key: Verb.archiveYes.rawValue)
            self.archiveNo    = b.localized(key: Verb.archiveNo.rawValue)
            self.share        = b.localized(key: Verb.share.rawValue)
            self.tagApply     = b.localized(key: Verb.tagApply.rawValue)
            self.edit         = b.localized(key: Verb.editWebsite.rawValue)
            self.delete       = b.localized(key: Verb.deleteWebsite.rawValue)
            self.sort         = b.localized(key: Verb.sort.rawValue)
            self.error        = b.localized(key: Verb.errorsPresent.rawValue)
            self.selectAll    = b.localized(key: Verb.selectAll.rawValue)
            self.deselectAll  = b.localized(key: Verb.deselectAll.rawValue)
            self.itemsCount = {
                // TODO: Use Strings Dictionary
                // https://developer.apple.com/documentation/xcode/localizing-strings-that-contain-plurals
                return "\($0)項目"
            }
            self.itemSelectedTotal = {
                return "\($1)項目中の\($0)項目を選択"
            }
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
