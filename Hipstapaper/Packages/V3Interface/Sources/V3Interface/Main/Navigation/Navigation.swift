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
import Collections
import Umbrella
import V3Model
import V3Errors

internal struct Navigation: Hashable, Codable, ErrorPresentable {
    
    internal var sidebar = Sidebar()
    internal var detail  = Detail()
    internal var isWebsitesEdit: Website.Selection = []
    internal var isError: CodableError?
    
    internal var isPresenting: Bool {
        self.detail.isPresenting
        || !self.isWebsitesEdit.isEmpty
        || self.sidebar.isPresenting
        || self.isError != nil
    }
}

extension Navigation {
    internal struct Sidebar: Hashable, Codable, ErrorPresentable {
        internal var selectedTag: Tag.Selection.Element?
        internal var isTagsEdit: TagsEdit = .init()
        internal var isError: CodableError? // Not used
        internal var isPresenting: Bool {
            !self.isTagsEdit.editing.isEmpty
            || self.isError != nil
        }
    }
    internal struct Detail: Hashable, Codable, ErrorPresentable {
        internal var selectedWebsites: Website.Selection = []
        internal var isErrorList: Basic = .init()
        internal var isTagApply: Website.Selection = []
        internal var isTagApplyPopover: Website.Selection = []
        internal var isShare: Website.Selection = []
        internal var isSharePopover: Website.Selection = []
        internal var isBrowse: Website.Selection.Element? = nil
        internal var isError: CodableError? // Not used
        internal var isPresenting: Bool {
            !self.isTagApply.isEmpty
            || !self.isShare.isEmpty
            || !self.isSharePopover.isEmpty
            || self.isBrowse != nil
            || self.isError != nil
        }
    }
    internal struct TagsEdit: Hashable, Codable, ErrorPresentable {
        internal var editing: Tag.Selection = []
        internal var isError: CodableError?
        internal var isPresenting: Bool {
            self.isError != nil
        }
    }
    internal struct Basic: Hashable, Codable, ErrorPresentable {
        internal var isError: CodableError?
        internal var isPresented: Bool = false
        internal var isPresenting: Bool {
            self.isError != nil
        }
    }
}
