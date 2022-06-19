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
public struct Sidebar: DynamicProperty {
    
    public struct Value {
        public var navigationTitle: LocalizedString
        public var sectionTitleTagsSystem: LocalizedString
        public var sectionTitleTagsUser: LocalizedString
        public var rowTitleTagSystemUnread: LocalizedString
        public var rowTitleTagSystemAll: LocalizedString
        public var rowTitleUntitled: LocalizedString
        public var toolbarAddTag: LocalizedString
        public var toolbarAddWebsite: LocalizedString
        public var toolbarAddGeneric: LocalizedString
        public var menuEditTags: LocalizedString
        public var menuDeleteTags: LocalizedString
        
        internal init(_ b: LocalizeBundle) {
            self.navigationTitle         = b.localized(key: Noun.tags.rawValue)
            self.sectionTitleTagsSystem  = b.localized(key: Noun.readingList.rawValue)
            self.sectionTitleTagsUser    = b.localized(key: Noun.tags.rawValue)
            self.rowTitleTagSystemUnread = b.localized(key: Noun.unreadItems.rawValue)
            self.rowTitleTagSystemAll    = b.localized(key: Noun.allItems.rawValue)
            self.rowTitleUntitled        = b.localized(key: Noun.untitled.rawValue)
            self.toolbarAddTag           = b.localized(key: Verb.addTag.rawValue)
            self.toolbarAddWebsite       = b.localized(key: Verb.addWebsite.rawValue)
            self.toolbarAddGeneric       = b.localized(key: Verb.addChoice.rawValue)
            self.menuEditTags            = b.localized(key: Verb.editTags.rawValue)
            self.menuDeleteTags          = b.localized(key: Verb.editWebsite.rawValue)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
