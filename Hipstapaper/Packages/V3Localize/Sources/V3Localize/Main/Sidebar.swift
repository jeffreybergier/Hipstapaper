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
    
    internal struct RV {
        static let navigationTitle = Noun.tags
        static let sectionTitleTagsSystem = Noun.readingList
        static let sectionTitleTagsUser = Noun.tags
        static let rowTitleTagSystemUnread = Noun.unreadItems
        static let rowTitleTagSystemAll = Noun.allItems
    }
    
    public struct Value {
        public var navigationTitle: LocalizedString
        public var sectionTitleTagsSystem: LocalizedString
        public var sectionTitleTagsUser: LocalizedString
        public var rowTitleTagSystemUnread: LocalizedString
        public var rowTitleTagSystemAll: LocalizedString
        internal init(_ b: LocalizeBundle) {
            self.navigationTitle = b.localized(key: RV.navigationTitle.rawValue)
            self.sectionTitleTagsSystem = b.localized(key: RV.sectionTitleTagsSystem.rawValue)
            self.sectionTitleTagsUser = b.localized(key: RV.sectionTitleTagsUser.rawValue)
            self.rowTitleTagSystemUnread = b.localized(key: RV.rowTitleTagSystemUnread.rawValue)
            self.rowTitleTagSystemAll = b.localized(key: RV.rowTitleTagSystemAll.rawValue)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
