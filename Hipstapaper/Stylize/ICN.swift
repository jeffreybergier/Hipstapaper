//
//  Created by Jeffrey Bergier on 2021/02/20.
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
