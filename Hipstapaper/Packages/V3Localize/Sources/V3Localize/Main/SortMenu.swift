//
//  Created by Jeffrey Bergier on 2022/06/26.
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
public struct SortMenu: DynamicProperty {
    
    public struct Value {
        public var menu: LocalizedString
        public var sortTitleA: LocalizedString
        public var sortTitleZ: LocalizedString
        public var sortDateCreatedNewest: LocalizedString
        public var sortDateCreatedOldest: LocalizedString
        public var sortDateModifiedNewest: LocalizedString
        public var sortDateModifiedOldest: LocalizedString
        
        internal init(_ b: LocalizeBundle) {
            self.menu = b.localized(key: Verb.sort.rawValue)
            self.sortTitleA = b.localized(key: Verb.sortTitleA.rawValue)
            self.sortTitleZ = b.localized(key: Verb.sortTitleZ.rawValue)
            self.sortDateCreatedNewest = b.localized(key: Verb.sortDateCreatedNewest.rawValue)
            self.sortDateCreatedOldest = b.localized(key: Verb.sortDateCreatedOldest.rawValue)
            self.sortDateModifiedNewest = b.localized(key: Verb.sortDateModifiedNewest.rawValue)
            self.sortDateModifiedOldest = b.localized(key: Verb.sortDateModifiedOldest.rawValue)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
