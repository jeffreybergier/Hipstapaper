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

public enum Phrase: LocalizationKey {
    case addChoice              = "Phrase.AddChoice"
    case sort                   = "Phrase.Sort"
    case filterA                = "Phrase.FilterA"
    case filterB                = "Phrase.FilterB"
    case errorScreenshot        = "Phrase.ErrorScreenshot"
    case errorConvertImage      = "Phrase.ErrorConvertImage"
    case errorImageSize         = "Phrase.ImageSize"
    case errorUserCancel        = "Phrase.UserCancel"
    case errorProcessURL        = "Phrase.ProcessURL"
    case errorSaveWebsite       = "Phrase.SaveWebsite"
    case share                  = "Phrase.Share"
    case unarchive              = "Phrase.Unarchive"
    case archive                = "Phrase.Archive"
    case safari                 = "Phrase.OpenInBrowser"
    case openInApp              = "Phrase.OpenInApp"
    case stopLoading            = "Phrase.StopLoading"
    case loadPage               = "Phrase.LoadPage"
    case reloadPage             = "Phrase.ReloadPage"
    case jsActive               = "Phrase.JSActive"
    case jsInactive             = "Phrase.JSInactive"
    case goBack                 = "Phrase.GoBack"
    case goForward              = "Phrase.GoForward"
    case deleteTagTip           = "Phrase.DeleteTagTip"
    case deleteWebsiteTip       = "Phrase.DeleteWebsiteTip"
    case deleteTagConfirm       = "Phrase.DeleteTagConfirm"
    case deleteWebsiteConfirm   = "Phrase.DeleteWebsiteConfirm"
    case clearSearch            = "Phrase.ClearSearch"
    case iCloudAccountError     = "Phrase.iCloudAccountError"
    case iCloudSyncError        = "Phrase.iCloudSyncError"
    case addAndRemoveTags       = "Phrase.AddAndRemoveTags"
    case searchWebsite          = "Phrase.SearchWebsite"
    case addTag                 = "Phrase.AddTag"
    case editTag                = "Phrase.EditTag"
    case addWebsite             = "Phrase.AddWebsite"
    case done                   = "Phrase.Done"
    case save                   = "Phrase.Save"
    case cancel                 = "Phrase.Cancel"
    case errorInvalidURL        = "Phrase.ErrorInvalidURL%@"
    case erroriCloudAccount     = "Phrase.ErroriCloudAccount"
    case errorShareItemCount    = "Phrase.ErrorShareItemCount"
    case errorLoadURL           = "Phrase.ErrorLoadURL"
    case errorShareImport       = "Phrase.ErrorShareImport"
}
