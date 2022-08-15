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
        public var navigationTitle:         LocalizedString
        public var sectionTitleTagsSystem:  LocalizedString
        public var sectionTitleTagsUser:    LocalizedString
        public var rowTitleTagSystemUnread: LocalizedString
        public var rowTitleTagSystemAll:    LocalizedString
        public var rowTitleUntitled:        LocalizedString
        public var toolbarAddTag:           ActionLocalization
        public var toolbarAddWebsite:       ActionLocalization
        public var toolbarAddGeneric:       ActionLocalization
        public var menuEditTags:            ActionLocalization
        public var menuDeleteTags:          ActionLocalization
        public var noTags:                  ActionLocalization
        
        internal init(_ b: LocalizeBundle) {
            self.navigationTitle         = b.localized(key: Noun.tags.rawValue)
            self.sectionTitleTagsSystem  = b.localized(key: Noun.readingList.rawValue)
            self.sectionTitleTagsUser    = b.localized(key: Noun.tags.rawValue)
            self.rowTitleTagSystemUnread = b.localized(key: Noun.unreadItems.rawValue)
            self.rowTitleTagSystemAll    = b.localized(key: Noun.allItems.rawValue)
            self.rowTitleUntitled        = b.localized(key: Noun.untitled.rawValue)
            self.toolbarAddTag           = .addTag(b)
            self.toolbarAddWebsite       = .addWebsite(b)
            self.toolbarAddGeneric       = .addChoice(b)
            self.menuEditTags            = .editTag(b)
            self.menuDeleteTags          = .deleteTag(b)
            self.noTags                  = .noContentTag(b)
            
            // TODO: Toolbar shortcuts conflict with MainMenu shortcuts
            // Remove shortcuts for toolbar items
            self.toolbarAddTag.shortcut     = nil
            self.toolbarAddWebsite.shortcut = nil
            self.toolbarAddGeneric.shortcut = nil
            self.menuEditTags.shortcut      = nil
            self.menuDeleteTags.shortcut    = nil
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
