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
        public var tabWebsite:         LocalizedString
        public var tabTag:             LocalizedString
        public var done:               LocalizedString
        public var delete:             LocalizedString
        public var deleteThumbnail:    LocalizedString
        public var untitled:           LocalizedString
        public var autofill:           LocalizedString
        public var stop:               LocalizedString
        public var jsYes:              LocalizedString
        public var jsNo:               LocalizedString
        public var websiteTitle:       LocalizedString
        public var originalURL:        LocalizedString
        public var resolvedURL:        LocalizedString
        public var noWebsitesSelected: LocalizedString
        public var noTagSelected:      LocalizedString
        public var noTags:             LocalizedString
        public var error:              LocalizedString
        
        internal init(_ b: LocalizeBundle) {
            self.titleWebsite       = b.localized(key: Noun.editWebsite.rawValue)
            self.titleTag           = b.localized(key: Noun.tagApply.rawValue)
            self.tabWebsite         = b.localized(key: Noun.website.rawValue)
            self.tabTag             = b.localized(key: Noun.tags.rawValue)
            self.done               = b.localized(key: Verb.done.rawValue)
            self.delete             = b.localized(key: Verb.deleteGeneric.rawValue)
            self.deleteThumbnail    = b.localized(key: Verb.deleteImage.rawValue)
            self.untitled           = b.localized(key: Noun.untitled.rawValue)
            self.autofill           = b.localized(key: Verb.autofill.rawValue)
            self.stop               = b.localized(key: Verb.stopLoading.rawValue)
            self.jsYes              = b.localized(key: Verb.javascriptYes.rawValue)
            self.jsNo               = b.localized(key: Verb.javascriptNo.rawValue)
            self.websiteTitle       = b.localized(key: Noun.websiteTitle.rawValue)
            self.originalURL        = b.localized(key: Noun.originalURL.rawValue)
            self.resolvedURL        = b.localized(key: Noun.resolvedURL.rawValue)
            self.noWebsitesSelected = b.localized(key: Phrase.noSelectionWebsite.rawValue)
            self.noTagSelected      = b.localized(key: Phrase.noSelectionTag.rawValue)
            self.noTags             = b.localized(key: Phrase.noTags.rawValue)
            self.error              = b.localized(key: Verb.errorsPresent.rawValue)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
