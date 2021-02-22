//
//  Created by Jeffrey Bergier on 2021/02/20.
//
//  Copyright © 2020 Saturday Apps.
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
    }
}
