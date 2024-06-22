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

internal enum Phrase: LocalizationKey {
    case addChoice                 = "Phrase.AddChoice"
    case sort                      = "Phrase.Sort"
    case sortDateModifiedNewest    = "Phrase.SortDateModifiedNewest"
    case sortDateModifiedOldest    = "Phrase.SortDateModifiedOldest"
    case sortDateCreatedNewest     = "Phrase.SortDateCreatedNewest"
    case sortDateCreatedOldest     = "Phrase.SortDateCreatedOldest"
    case sortTitleA                = "Phrase.SortTitleA"
    case sortTitleZ                = "Phrase.SortTitleZ"
    case filter                    = "Phrase.Filter"
    case filterYes                 = "Phrase.FilterYes"
    case filterNo                  = "Phrase.FilterNo"
    case errorScreenshot           = "Phrase.ErrorScreenshot"
    case errorConvertImage         = "Phrase.ErrorConvertImage"
    case errorImageSize            = "Phrase.ImageSize"
    case errorUserCancel           = "Phrase.UserCancel"
    case errorProcessURL           = "Phrase.ProcessURL"
    case errorSaveWebsite          = "Phrase.SaveWebsite"
    case errorUnknown              = "Phrase.ErrorUnknown"
    case share                     = "Phrase.Share"
    case shareError                = "Phrase.ShareError"
    case unarchive                 = "Phrase.Unarchive"
    case archive                   = "Phrase.Archive"
    case openExternal              = "Phrase.OpenInBrowser"
    case openInApp                 = "Phrase.OpenInApp"
    case stopLoading               = "Phrase.StopLoading"
    case loadPage                  = "Phrase.LoadPage"
    case loadingPage               = "Phrase.LoadingPage"
    case reloadPage                = "Phrase.ReloadPage"
    case jsActive                  = "Phrase.JSActive"
    case jsInactive                = "Phrase.JSInactive"
    case goBack                    = "Phrase.GoBack"
    case goForward                 = "Phrase.GoForward"
    case deleteTagTip              = "Phrase.DeleteTagTip"
    case deleteWebsiteTip          = "Phrase.DeleteWebsiteTip"
    case deleteTagConfirm          = "Phrase.DeleteTagConfirm"
    case deleteWebsiteConfirm      = "Phrase.DeleteWebsiteConfirm"
    case deleteImageTip            = "Phrase.DeleteImageTip"
    case editWebsiteTip            = "Phrase.EditWebsiteTip"
    case clearSearch               = "Phrase.ClearSearch"
    case addAndRemoveTags          = "Phrase.AddAndRemoveTags"
    case searchWebsite             = "Phrase.SearchWebsite"
    case addTag                    = "Phrase.AddTag"
    case editTag                   = "Phrase.EditTag"
    case viewQRCode                = "Phrase.ViewQRCode"
    case addWebsite                = "Phrase.AddWebsite"
    case done                      = "Phrase.Done"
    case save                      = "Phrase.Save"
    case cancel                    = "Phrase.Cancel"
    case errorInvalidURL           = "Phrase.ErrorInvalidURL%@"
    case errorShareItemCount       = "Phrase.ErrorShareItemCount"
    case errorLoadURL              = "Phrase.ErrorLoadURL"
    case errorShareImport          = "Phrase.ErrorShareImport"
    case errorCloudAccount         = "Phrase.errorCloudAccount"
    case errorCloudSync            = "Phrase.errorCloudSync"
    case noSelectionTag            = "Phrase.NoTagSelection"
    case noSelectionWebsite        = "Phrase.NoWebsiteSelection"
    case noTags                    = "Phrase.NoTags"
    case noWebsites                = "Phrase.NoWebsites"
    case noQRCode                  = "Phrase.NoQRCode"
    case copyToClipboard           = "Phrase.CopyToClipboard"
    case permissionCameraIncapable = "Phrase.PermissionCameraIncapable"
    case permissionCameraDenied    = "Phrase.PermissionCameraDenied"
    case permissionCameraNeeded    = "Phrase.PermissionCameraNeeded"
}
