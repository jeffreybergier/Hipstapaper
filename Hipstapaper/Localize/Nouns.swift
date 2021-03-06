//
//  Created by Jeffrey Bergier on 2020/12/24.
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

public enum Noun: LocalizedStringKey {
    case search        = "Noun.Search"
    case readingList   = "Noun.ReadingList"
    case tags          = "Noun.Tags"
    case untitled      = "Noun.Untitled"
    case allItems      = "Noun.AllItems"
    case unreadItems   = "Noun.UnreadItems"
    case websiteURL    = "Noun.WebsiteURL"
    case websiteTitle  = "Noun.WebsiteTitle"
    case hipstapaper   = "Noun.Hipstapaper"
    case tagName       = "Noun.TagName"
    case addChoice     = "Noun.AddChoice"
    case addTag        = "Noun.AddTag"
    case editTag       = "Noun.EditTag"
    case addWebsite    = "Noun.AddWebsite"
    case applyTags     = "Noun.ApplyTags"
    case sort          = "Noun.Sort"
    case filter        = "Noun.Filter"
    case error         = "Noun.Error"
    case errorDatabase = "Noun.ErrorDatabase"
    case erroriCloud   = "Noun.iCloud"
    case deleteTag     = "Noun.DeleteTag"
    case deleteWebsite = "Noun.DeleteWebsite"
    
    public static let allItems_L: String = NSLocalizedString("Noun.AllItems", comment: "")
    public static let unreadItems_L: String = NSLocalizedString("Noun.UnreadItems", comment: "")
    public static let untitled_L: String = NSLocalizedString("Noun.Untitled", comment: "")
}
