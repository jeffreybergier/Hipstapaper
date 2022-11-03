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
        public var menu:                   ActionLocalization
        public var sortTitleA:             ActionLocalization
        public var sortTitleZ:             ActionLocalization
        public var sortDateCreatedNewest:  ActionLocalization
        public var sortDateCreatedOldest:  ActionLocalization
        public var sortDateModifiedNewest: ActionLocalization
        public var sortDateModifiedOldest: ActionLocalization
        
        internal init(_ b: LocalizeBundle) {
            self.menu                   = Action.sort.localized(b)
            self.sortTitleA             = Action.sortTitleA.localized(b)
            self.sortTitleZ             = Action.sortTitleZ.localized(b)
            self.sortDateCreatedNewest  = Action.sortDateCreatedNewest.localized(b)
            self.sortDateCreatedOldest  = Action.sortDateCreatedOldest.localized(b)
            self.sortDateModifiedNewest = Action.sortDateModifiedNewest.localized(b)
            self.sortDateModifiedOldest = Action.sortDateModifiedOldest.localized(b)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
