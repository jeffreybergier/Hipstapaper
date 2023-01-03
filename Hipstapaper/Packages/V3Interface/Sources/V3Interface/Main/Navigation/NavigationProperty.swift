//
//  Created by Jeffrey Bergier on 2022/06/17.
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
import V3Model

@propertyWrapper
internal struct Navigation: DynamicProperty {
    @JSBSceneStorage("com.hipstapaper.nav") private var storage = Value()
    internal var wrappedValue: Value {
        get { self.storage }
        nonmutating set { self.storage = newValue }
    }
    internal var projectedValue: Binding<Value> {
        self.$storage
    }
}

extension Navigation {
    internal struct Value: Hashable, Codable {
        internal var sidebar:        Sidebar = .init()
        internal var detail:         Detail  = .init()
        internal var isWebsitesEdit: Website.Selection = []
        internal var isError:        CodableError?
    }
    internal struct Sidebar: Hashable, Codable {
        internal var isTagsEdit: TagsEdit = .init()
    }
    internal struct Detail: Hashable, Codable {
        internal var isErrorList:       Basic = .init()
        internal var isTagApply:        Website.Selection = []
        internal var isTagApplyPopover: Website.Selection = []
        internal var isShare:           Website.Selection = []
        internal var isSharePopover:    Website.Selection = []
        internal var isBrowse:          Website.Selection.Element? = nil
    }
    internal struct TagsEdit: Hashable, Codable {
        internal var isError:     CodableError?
        internal var isPresented: Tag.Selection = []
    }
    internal struct Basic: Hashable, Codable {
        internal var isPresented: Bool = false
    }
}

// MARK: isPresenting Hack
/*
 `IsPresenting` is used when presenting programmatically, like Errors.
 If this returns yes, nothing new should be presented unless dismissing
 everything else.
 
 This is a pretty broken system as I can't detect when the system
 is presenting (like menus). Also, the error in the console for trying
 to present multiple items is not catcable or detectable.
 
 Modal presentation in SwiftUI is fundamentally broken because there is no
 Environment variable to check `isPresenting`. Also there is no way to force
 the system to dismiss all presented views.
 */

extension Navigation.Value {
    internal var isPresenting: Bool {
           self.detail.isPresenting
        || self.sidebar.isPresenting
        || self.isWebsitesEdit.isEmpty == false
        || self.isError != nil
    }
}

extension Navigation.Sidebar {
    internal var isPresenting: Bool {
        self.isTagsEdit.isPresented.isEmpty == false
    }
}

extension Navigation.Detail {
    internal var isPresenting: Bool {
           self.isErrorList.isPresented
        || self.isTagApply.isEmpty        == false
        || self.isTagApplyPopover.isEmpty == false
        || self.isShare.isEmpty           == false
        || self.isSharePopover.isEmpty    == false
        || self.isBrowse                  != nil
    }
}

extension Navigation.TagsEdit {
    internal var isPresenting: Bool {
        self.isError != nil
    }
}
