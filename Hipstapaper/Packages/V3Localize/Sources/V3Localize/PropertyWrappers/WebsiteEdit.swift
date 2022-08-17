//
//  Created by Jeffrey Bergier on 2022/06/25.
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
public struct WebsiteEdit: DynamicProperty {
    
    public struct Value {
        public var titleWebsite:       LocalizedString
        public var titleTag:           LocalizedString
        public var untitled:           LocalizedString
        public var websiteTitle:       LocalizedString
        public var originalURL:        LocalizedString
        public var resolvedURL:        LocalizedString
        public var done:               LocalizedString
        public var delete:             LocalizedString
        public var tabWebsite:         LocalizedString
        public var tabTag:             LocalizedString
        public var deleteThumbnail:    LocalizedString
        public var autofill:           LocalizedString
        
//        public var tabWebsite:         ActionLocalization
//        public var tabTag:             ActionLocalization
//        public var deleteThumbnail:    ActionLocalization
//        public var autofill:           ActionLocalization
        public var stop:               ActionLocalization
        public var jsYes:              ActionLocalization
        public var jsNo:               ActionLocalization
        public var noWebsitesSelected: ActionLocalization
        public var noTagSelected:      ActionLocalization
        public var noTags:             ActionLocalization
        public var error:              ActionLocalization
        
        internal init(_ b: LocalizeBundle) {
            self.titleWebsite       = b.localized(key: Noun.editWebsite.rawValue)
            self.titleTag           = b.localized(key: Noun.tagApply.rawValue)
            self.untitled           = b.localized(key: Noun.untitled.rawValue)
            self.websiteTitle       = b.localized(key: Noun.websiteTitle.rawValue)
            self.originalURL        = b.localized(key: Noun.originalURL.rawValue)
            self.resolvedURL        = b.localized(key: Noun.resolvedURL.rawValue)
            self.done               = b.localized(key: Verb.done.rawValue)
            self.delete             = b.localized(key: Verb.deleteGeneric.rawValue)
            self.tabWebsite         = b.localized(key: Noun.website.rawValue)
            self.tabTag             = b.localized(key: Noun.tags.rawValue)
            self.deleteThumbnail    = b.localized(key: Verb.deleteImage.rawValue)
            self.autofill           = b.localized(key: Verb.autofill.rawValue)
            self.stop               = .browseStop(b)
            self.jsYes              = .javascriptYes(b)
            self.jsNo               = .javascriptNo(b)
            self.noWebsitesSelected = .noSelectionWebsite(b)
            self.noTagSelected      = .noSelectionTag(b)
            self.noTags             = .noContentTag(b)
            self.error              = .errorsPresent(b)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
