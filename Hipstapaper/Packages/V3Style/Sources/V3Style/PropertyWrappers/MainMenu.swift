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

@propertyWrapper
public struct MainMenu: DynamicProperty {
    
    public init() {}
    
    public struct Value {
        public var openInApp     = Action.openInApp
        public var openExternal  = Action.openExternal
        public var archiveYes    = Action.archiveYes
        public var archiveNo     = Action.archiveNo
        public var share         = Action.share
        public var tagApply      = Action.tagApply
        public var websiteAdd    = Action.websiteAdd
        public var tagAdd        = Action.tagAdd
        public var websiteEdit   = Action.genericEdit
        public var tagEdit       = Action.tagEdit
        public var websiteDelete = Action.genericDelete
        public var tagDelete     = Action.tagDelete
        public var error         = Action.errorPresent
        public var selectAll     = Action.selectAll
        public var deselectAll   = Action.deselectAll
        public func syncIndicator(_ progress: Progress) -> some ViewModifier {
            SyncIndicator(progress)
        }
    }
    
    public var wrappedValue: Value {
        Value()
    }
}
