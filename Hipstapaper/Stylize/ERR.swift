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

extension Alert {
    fileprivate init(error: LocalizedError, dismissAction: Action?) {
        self.init(title: Text(Noun.Error),
                  message: Text(error.errorDescription!),
                  dismissButton: .default(Text(Verb.Dismiss),
                                          action: { dismissAction?() }))
    }
    fileprivate init(error: LocalizedError, dismissAction: STZ.ERR.Legacy.Action?) {
        self.init(title: Text(Noun.Error),
                  message: Text(error.errorDescription!),
                  dismissButton: .default(Text(Verb.Dismiss),
                                          action: { dismissAction?(error) }))
    }
}

extension STZ.ERR {
    public enum Legacy {
        public typealias Action = (Error) -> Void
        /// Set an error here to present an Alert when using with
        /// Presenter / Modifier
        public class ViewModel: ObservableObject {
            @Published public var error: LocalizedError? {
                didSet {
                    let shouldBe = self.error != nil
                    guard shouldBe != self.isPresented else { return }
                    self.isPresented = shouldBe
                }
            }
            @Published internal var isPresented = false {
                didSet {
                    guard self.isPresented == false else { return }
                    self.error = nil
                }
            }
            /// Closure is called when alert is dismissed
            public var dismissAction: Action?
            internal var alert: Alert? {
                guard let error = self.error else { return nil }
                return Alert(error: error, dismissAction: self.dismissAction)
            }
            public init() {}
        }
        
        /// If the ViewModel contains an Error, this presents an Alert,
        /// otherwise is transparent view.
        /// Use when needing to present SwiftUI alert from UIKit
        public struct Presenter: View {
            @ObservedObject public var viewModel: ViewModel
            public var body: some View {
                Color.clear.alert(isPresented: self.$viewModel.isPresented,
                                  content: { self.viewModel.alert! })
            }
            public init(_ viewModel: ViewModel) {
                _viewModel = .init(wrappedValue: viewModel)
            }
        }
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
