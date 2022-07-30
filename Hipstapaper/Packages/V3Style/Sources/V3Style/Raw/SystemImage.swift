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

internal enum SystemImage: String {
    case tag               = "tag"
    case plus              = "plus"
    case website           = "doc.text.image"
    case openInApp         = "safari"
    case openExternal      = "safari.fill"
    case archiveYes        = "tray.and.arrow.down"
    case archiveNo         = "tray.and.arrow.up"
    case filterYes         = "line.horizontal.3.decrease.circle.fill"
    case filterNo          = "line.horizontal.3.decrease.circle"
    case sort              = "arrow.up.arrow.down.circle"
    case share             = "square.and.arrow.up"
    case deleteMinus       = "minus"
    case deleteTrash       = "trash"
    case editPencil        = "rectangle.and.pencil.and.ellipsis"
    case document          = "doc.richtext"
    case documentFill      = "doc.richtext.fill"
    case calendar          = "calendar.circle"
    case calendarFill      = "calendar.circle.fill"
    case errorGeneric      = "exclamationmark.triangle"
    case browseBack        = "chevron.backward"
    case browseForward     = "chevron.forward"
    case browseReload      = "arrow.clockwise"
    case browseStop        = "xmark"
    case javascriptYes     = "applescript.fill"
    case javascriptNo      = "applescript"
    case magic             = "wand.and.stars"
    case minusRectangle    = "rectangle.badge.minus"
    case checkmark         = "checkmark"
    case photo             = "photo"
    case rectangleSlash    = "rectangle.on.rectangle.slash"
    case iCloudSync        = "arrow.clockwise.icloud"
    case columnGeneric     = "building.columns"
    case columnCircleFill  = "building.columns.circle.fill"
    case columnCircleEmpty = "building.columns.circle"
}

/*
 extension STZ {
     public enum ICN: String, View {
         public var body: Image { Image(systemName: self.rawValue) }
         case share = "square.and.arrow.up"
         case unarchive = "tray.and.arrow.up"
         case archive = "tray.and.arrow.down"
         case openInBrowser = "safari.fill"
         case openInApp = "safari"
         case filterActive = "line.horizontal.3.decrease.circle.fill"
         case filterInactive = "line.horizontal.3.decrease.circle"
         case stop = "xmark"
         case reload = "arrow.clockwise"
         case jsActive = "applescript.fill"
         case jsInactive = "applescript"
         case goBack = "chevron.backward"
         case goForward = "chevron.forward"
         case deleteMinus = "minus"
         case deleteTrash = "trash"
         case editPencil = "rectangle.and.pencil.and.ellipsis"
         case clearSearch = "xmark.circle"
         case cloudError = "exclamationmark.icloud"
         case cloudSyncSuccess = "checkmark.icloud"
         case cloudSyncInProgress = "arrow.clockwise.icloud"
         case cloudAccountError = "icloud.slash"
         case tag = "tag"
         case searchInactive = "magnifyingglass"
         case searchActive = "magnifyingglass.circle.fill"
         case sort = "arrow.up.arrow.down.circle"
         case addPlus = "plus"
         case web = "globe"
         case bug = "ladybug"
         case placeholder = "photo"
         case sortTitleA = "doc.richtext"
         case sortTitleZ = "doc.richtext.fill"
         case sortDateNewest = "calendar.circle"
         case sortDateOldest = "calendar.circle.fill"
     }
 }

 */
