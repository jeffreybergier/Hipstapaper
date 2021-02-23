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

public enum Verb: LocalizedStringKey {
    case save                   = "Verb.Save"
    case done                   = "Verb.Done"
    case cancel                 = "Verb.Cancel"
    case dismiss                = "Verb.Dismiss"
    case search                 = "Verb.Search"
    case archive                = "Verb.Archive"
    case unarchive              = "Verb.Unarchive"
    case share                  = "Verb.Share"
    case addChoice              = "Verb.AddChoice"
    case addTag                 = "Verb.AddTag"
    case addWebsite             = "Verb.AddWebsite"
    case deleteTag              = "Verb.DeleteTag"
    case deleteWebsite          = "Verb.DeleteWebsite"
    case go                     = "Verb.Go"
    case clearSearch            = "Verb.ClearSearch"
    case openInApp              = "Verb.OpenInApp"
    case safari                 = "Verb.OpenInBrowser"
    case addAndRemoveTags       = "Verb.AddAndRemoveTags"
    case filter                 = "Verb.Filter"
    case stopLoading            = "Verb.StopLoading"
    case reloadPage             = "Verb.ReloadPage"
    case javascript             = "Verb.Javascript"
    case goBack                 = "Verb.GoBack"
    case goForward              = "Verb.GoForward"
    case iCloud                 = "Verb.iCloud"
    case sort                   = "Verb.Sort"
    case sortDateModifiedNewest = "Verb.SortDateModifiedNewest"
    case sortDateModifiedOldest = "Verb.SortDateModifiedOldest"
    case sortDateCreatedNewest  = "Verb.SortDateCreatedNewest"
    case sortDateCreatedOldest  = "Verb.SortDateCreatedOldest"
    case sortTitleA             = "Verb.SortTitleA"
    case sortTitleZ             = "Verb.SortTitleZ"

}
