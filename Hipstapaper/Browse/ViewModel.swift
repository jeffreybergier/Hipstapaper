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

public class ViewModel: ObservableObject {
    
    public class BrowserControl: ObservableObject {
        @Published public var stop = false
        @Published public var reload = false
        @Published public var goBack = false
        @Published public var goForward = false
        @Published public var load: URL?
        deinit {
            // TODO: Remove once toolbar leaks are fixed
            print("Browser Control DEINIT")
        }
    }
    
    public class BrowserDisplay: ObservableObject {
        @Published public internal(set) var title = ""
        @Published public internal(set) var urlString = ""
        @Published public internal(set) var isSharing = false
        @Published public internal(set) var isLoading: Bool = false
        @Published public internal(set) var canGoBack: Bool = false
        @Published public internal(set) var canGoForward: Bool = false
        public let progress = Progress(totalUnitCount: 100)
        internal var kvo: [NSKeyValueObservation] = []
        deinit {
            // TODO: Remove once toolbar leaks are fixed
            print("Browser Display DEINIT")
        }
    }
    
    public class ItemDisplay: ObservableObject {
        @Published public var isJSEnabled = false
        @Published public var isArchived: Bool = false
        deinit {
            // TODO: Remove once toolbar leaks are fixed
            print("ItemDisplay DEINIT")
        }
    }
    
    public let originalURL: URL
    public let doneAction: (() -> Void)?
    @Published public var browserControl = BrowserControl()
    @Published public var browserDisplay = BrowserDisplay()
    @Published public var itemDisplay = ItemDisplay()
    
    public init(url: URL, doneAction: (() -> Void)?) {
        self.originalURL = url
        self.doneAction = doneAction
    }
    
    deinit {
        // TODO: Remove once toolbar leaks are fixed
        print("Browser ViewModel DEINIT")
    }
}
