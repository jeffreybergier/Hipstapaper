//
//  Created by Jeffrey Bergier on 2021/01/10.
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
import Umbrella
import Localize

extension STZ {
    public enum ERR {
    }
}

import WebKit

extension STZ.ERR {
    public class WKDelegate: NSObject, WKNavigationDelegate {
        
        // TODO: Localize this error
        public enum Error: UserFacingError {
            case invalidURL(URL)
            public var message: LocalizedStringKey {
                switch self {
                case .invalidURL(let url):
                    return "Attempted to browse to an invalid URL: \(url.absoluteString)"
                }
            }
        }
        
        public typealias OnError = (UserFacingError) -> Void
        
        public let viewModel: ErrorQueue
        public var onError: OnError?
        
        public init(viewModel: ErrorQueue, onError: OnError? = nil) {
            self.viewModel = viewModel
            self.onError = onError
        }
        
        public func webView(_ webView: WKWebView,
                            decidePolicyFor navigationAction: WKNavigationAction,
                            preferences: WKWebpagePreferences,
                            decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void)
        {
            let url = navigationAction.request.url!
            guard
                let comp = URLComponents(url: url, resolvingAgainstBaseURL: true),
                comp.scheme == "http" || comp.scheme == "https" || comp.scheme == "about"
            else {
                decisionHandler(.cancel, preferences)
                let localizedError = Error.invalidURL(url)
                self.viewModel.queue.append(localizedError)
                self.onError?(localizedError)
                return
            }
            decisionHandler(.allow, preferences)
        }
        
        public func webView(_ webView: WKWebView,
                            didFail navigation: WKNavigation!,
                            withError error: Swift.Error)
        {
            let localizedError = GenericError(error as NSError)
            self.viewModel.queue.append(localizedError)
            self.onError?(localizedError)
        }
        
        public func webView(_ webView: WKWebView,
                            didFailProvisionalNavigation navigation: WKNavigation!,
                            withError error: Swift.Error)
        {
            let localizedError = GenericError(error as NSError)
            self.viewModel.queue.append(localizedError)
            self.onError?(localizedError)
        }
    }
}
