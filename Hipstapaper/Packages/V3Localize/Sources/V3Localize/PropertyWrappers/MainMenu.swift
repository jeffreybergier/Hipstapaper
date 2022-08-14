//
//  Created by Jeffrey Bergier on 2022/07/21.
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
public struct MainMenu: DynamicProperty {
    
    public struct Value {
        public var openInApp:     (LocalizeBundle) -> ActionLocalization
        public var openExternal:  (LocalizeBundle) -> ActionLocalization
        public var archiveYes:    (LocalizeBundle) -> ActionLocalization
        public var archiveNo:     (LocalizeBundle) -> ActionLocalization
        public var share:         (LocalizeBundle) -> ActionLocalization
        public var tagApply:      (LocalizeBundle) -> ActionLocalization
        public var websiteAdd:    (LocalizeBundle) -> ActionLocalization
        public var tagAdd:        (LocalizeBundle) -> ActionLocalization
        public var websiteEdit:   (LocalizeBundle) -> ActionLocalization
        public var tagEdit:       (LocalizeBundle) -> ActionLocalization
        public var websiteDelete: (LocalizeBundle) -> ActionLocalization
        public var tagDelete:     (LocalizeBundle) -> ActionLocalization
        public var deselectAll:   (LocalizeBundle) -> ActionLocalization
        public var error:         (LocalizeBundle) -> ActionLocalization
        
        public init() {
            self.openInApp     = { .convert(raw: .raw_openInApp,     b: $0) }
            self.openExternal  = { .convert(raw: .raw_openExternal,  b: $0) }
            self.archiveYes    = { .convert(raw: .raw_archiveYes,    b: $0) }
            self.archiveNo     = { .convert(raw: .raw_archiveNo,     b: $0) }
            self.share         = { .convert(raw: .raw_share,         b: $0) }
            self.tagApply      = { .convert(raw: .raw_tagApply,      b: $0) }
            self.websiteAdd    = { .convert(raw: .raw_addWebsite,    b: $0) }
            self.tagAdd        = { .convert(raw: .raw_addTag,        b: $0) }
            self.websiteEdit   = { .convert(raw: .raw_editWebsite,   b: $0) }
            self.tagEdit       = { .convert(raw: .raw_editTag,       b: $0) }
            self.websiteDelete = { .convert(raw: .raw_deleteWebsite, b: $0) }
            self.tagDelete     = { .convert(raw: .raw_deleteTag,     b: $0) }
            self.deselectAll   = { .convert(raw: .raw_deselectAll,   b: $0) }
            self.error         = { .convert(raw: .raw_errorsPresent, b: $0) }
        }
    }
        
    public init() {}
    
    public var wrappedValue: Value {
        Value()
    }
}
