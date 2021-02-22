//
//  Created by Jeffrey Bergier on 2021/01/06.
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

import Combine
import Umbrella

public class ViewModel: ObservableObject {
    
    public struct BrowserControl {
        public var stop = false
        public var reload = false
        public var goBack = false
        public var goForward = false
        public var load: URL?
    }
    
    public struct BrowserDisplay {
        public internal(set) var title = ""
        public internal(set) var urlString = ""
        public internal(set) var isSharing = false
        public internal(set) var isLoading: Bool = false
        public internal(set) var canGoBack: Bool = false
        public internal(set) var canGoForward: Bool = false
        public let progress = Progress(totalUnitCount: 100)
        internal var kvo: [NSKeyValueObservation] = []
    }
    
    public struct ItemDisplay {
        public var isJSEnabled = false
        public var isArchived: Bool = false
    }
    
    public let originalURL: URL?
    public let doneAction: (() -> Void)?
    @Published public var browserControl = BrowserControl()
    @Published public var browserDisplay = BrowserDisplay()
    @Published public var itemDisplay = ItemDisplay()
    
    public init(url: URL?, doneAction: (() -> Void)?) {
        self.originalURL = url
        self.doneAction = doneAction
        self.browserControl.load = originalURL
    }
    
    #if DEBUG
    deinit {
        log.verbose()
    }
    #endif
}
