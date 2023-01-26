//
//  Created by Jeffrey Bergier on 2022/07/17.
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
public struct Detail: DynamicProperty {
    
    public struct Value {
        public var titleUnread:   LocalizedString
        public var titleAll:      LocalizedString
        public var tagUntitled:   LocalizedString
        public var search:        LocalizedString
        public var noTagSelected: ActionLocalization
        public var noWebsites:    ActionLocalization
        
        internal init(_ b: Bundle) {
            self.titleUnread   = b.jsb_localized(key: Noun.unreadItems.rawValue)
            self.titleAll      = b.jsb_localized(key: Noun.allItems.rawValue)
            self.tagUntitled   = b.jsb_localized(key: Noun.untitled.rawValue)
            self.search        = b.jsb_localized(key: Verb.search.rawValue)
            self.noTagSelected = Action.noSelectionTag.localized(b)
            self.noWebsites    = Action.noContentWebsite.localized(b)
        }
    }
    
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        df.doesRelativeDateFormatting = true
        return df
    }()
    
    @Environment(\.bundle) private var bundle

    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
    
    public func dateString(_ date: Date?) -> LocalizedString {
        let missing = self.bundle.jsb_localized(key: Noun.dash.rawValue)
        return date.map { type(of: self).formatter.string(from: $0) }
                 ?? missing
    }
}
