//
//  Created by Jeffrey Bergier on 2021/01/06.
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

import Foundation
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
