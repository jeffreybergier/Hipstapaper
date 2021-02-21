//
//  Created by Jeffrey Bergier on 2020/12/24.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
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
    case addWebsite    = "Noun.AddWebsite"
    case applyTags     = "Noun.ApplyTags"
    case sort          = "Noun.Sort"
    case filter        = "Noun.Filter"
    case error         = "Noun.Error"
    case errorDatabase = "Noun.ErrorDatabase"
    
    public static let allItems_L: String = NSLocalizedString("Noun.AllItems", comment: "")
    public static let unreadItems_L: String = NSLocalizedString("Noun.UnreadItems", comment: "")
}
