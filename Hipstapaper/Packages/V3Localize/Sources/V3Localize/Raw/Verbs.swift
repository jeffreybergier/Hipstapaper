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
import Umbrella

internal enum Verb: LocalizationKey {
    case save                   = "Verb.Save"
    case done                   = "Verb.Done"
    case cancel                 = "Verb.Cancel"
    case dismiss                = "Verb.Dismiss"
    case search                 = "Verb.Search"
    case archiveYes             = "Verb.Archive"
    case archiveNo              = "Verb.Unarchive"
    case share                  = "Verb.Share"
    case addChoice              = "Verb.AddChoice"
    case addTag                 = "Verb.AddTag"
    case editTags               = "Verb.EditTags"
    case addWebsite             = "Verb.AddWebsite"
    case deleteTag              = "Verb.DeleteTag"
    case deleteWebsite          = "Verb.DeleteWebsite"
    case deleteImage            = "Verb.DeleteImage"
    case deleteGeneric          = "Verb.DeleteGeneric"
    case editWebsite            = "Verb.EditWebsite"
    case go                     = "Verb.Go"
    case clearSearch            = "Verb.ClearSearch"
    case openInApp              = "Verb.OpenInApp"
    case openExternal           = "Verb.OpenInBrowser"
    case tagApply               = "Verb.AddAndRemoveTags"
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
    case errorsPresent          = "Verb.ErrorsPresent"
    case clearAll               = "Verb.ClearAll"
}
