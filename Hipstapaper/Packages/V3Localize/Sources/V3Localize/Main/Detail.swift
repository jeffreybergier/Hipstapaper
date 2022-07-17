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
        public var titleUnread:        LocalizedString
        public var titleAll:           LocalizedString
        public var tagUntitled:        LocalizedString
        public var noSelection:        LocalizedString
        public var columnImage:        LocalizedString
        public var columnTitle:        LocalizedString
        public var columnURL:          LocalizedString
        public var columnDateCreated:  LocalizedString
        public var columnDateModified: LocalizedString
        public var missingTitle:       LocalizedString
        public var missingURL:         LocalizedString
        public var missingDate:        LocalizedString
        
        internal init(_ b: LocalizeBundle) {
            self.titleUnread        = b.localized(key: Noun.unreadItems.rawValue)
            self.titleAll           = b.localized(key: Noun.allItems.rawValue)
            self.tagUntitled        = b.localized(key: Noun.untitled.rawValue)
            self.noSelection        = b.localized(key: Phrase.noSelection.rawValue)
            self.columnImage        = b.localized(key: Noun.websiteTitle.rawValue)
            self.columnTitle        = b.localized(key: Noun.title.rawValue)
            self.columnURL          = b.localized(key: Noun.url.rawValue)
            self.columnDateCreated  = b.localized(key: Noun.dateCreated.rawValue)
            self.columnDateModified = b.localized(key: Noun.dateModified.rawValue)
            self.missingTitle       = b.localized(key: Noun.dash.rawValue)
            self.missingURL         = b.localized(key: Noun.dash.rawValue)
            self.missingDate        = b.localized(key: Noun.dash.rawValue)
        }
    }
    
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
    
    public func dateString(_ date: Date?) -> LocalizedString {
        let missing = self.bundle.localized(key: Noun.dash.rawValue)
        return date.map { type(of: self).formatter.string(from: $0) }
                 ?? missing
    }
}
