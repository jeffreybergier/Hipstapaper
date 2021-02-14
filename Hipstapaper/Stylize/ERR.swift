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
import Localize

extension STZ {
    public enum ERR {
    }
}

extension STZ.ERR {
    
    /// Add ViewModel to environment so any view can append errors.
    /// Use PresenterA or B at a high level in the view hierarchy
    /// to deque errors and present them to the user.
    public class ViewModel: ObservableObject {
        @Published public var isPresented = false
        @Published private var errors: [LocalizedError] = []
        public init() { }
        public func append(_ error: LocalizedError) {
            self.errors.append(error)
            self.updateIsPresented()
        }
        @discardableResult
        public func append<T, E: LocalizedError>(_ result: Result<T, E>) -> Result<T, E>
        {
            guard case .failure(let error) = result else { return result }
            self.append(error)
            return result
        }
        public func next() -> (LocalizedError, Action)? {
            guard let first = self.errors.first else { return nil }
            let closure = {
                DispatchQueue.main.async {
                    self.errors = Array(self.errors.dropFirst())
                    self.updateIsPresented()
                }
            }
            return (first, closure)
        }
        private func updateIsPresented() {
            self.isPresented = !self.errors.isEmpty
        }
    }
    
    /// Gets STZ.ERR.ViewModel from Initializer.
    /// Use `PresenterB` if you want to get ViewModel from Environment
    public struct PresenterA: ViewModifier {
        @ObservedObject private var viewModel: ViewModel
        public init(_ queue: ViewModel) {
            _viewModel = .init(initialValue: queue)
        }
        public func body(content: Content) -> some View {
            content.alert(isPresented: self.$viewModel.isPresented) {
                let next = self.viewModel.next()!
                return Alert(error: next.0, dismissAction: next.1)
            }
        }
    }
    
    /// Gets STZ.ERR.ViewModel from Environment.
    /// Use `PresenterA` if you don't want to use Environment
    public struct PresenterB: ViewModifier {
        @EnvironmentObject private var queue: ViewModel
        public init() {}
        public func body(content: Content) -> some View {
            content.alert(isPresented: self.$queue.isPresented) {
                let next = self.queue.next()!
                return Alert(error: next.0, dismissAction: next.1)
            }
        }
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
        
        public struct LError: LocalizedError {
            /// A localized message describing what error occurred.
            public var errorDescription: String?

            /// A localized message describing the reason for the failure.
            public var failureReason: String?

            /// A localized message providing "help" text if the user requests help.
            public var helpAnchor: String?
            
            public init(error: NSError) {
                self.errorDescription = error.localizedDescription
                self.failureReason = error.localizedFailureReason
                self.helpAnchor = error.helpAnchor
            }
        }
    }
}

import WebKit

extension STZ.ERR {
    public class WKDelegate: NSObject, WKNavigationDelegate {
        
        public enum Error: LocalizedError {
            case invalidURL(URL)
            public var errorDescription: String? {
                switch self {
                case .invalidURL(let url):
                    return "Attempted to browse to an invalid URL: \(url.absoluteString)"
                }
            }
        }
        
        public typealias OnError = (LocalizedError) -> Void
        
        public let viewModel: ViewModel
        public var onError: OnError?
        
        public init(viewModel: ViewModel, onError: OnError? = nil) {
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
                self.viewModel.append(localizedError)
                self.onError?(localizedError)
                return
            }
            decisionHandler(.allow, preferences)
        }
        
        public func webView(_ webView: WKWebView,
                            didFail navigation: WKNavigation!,
                            withError error: Swift.Error)
        {
            let localizedError = STZ.ERR.Legacy.LError(error: error as NSError)
            self.viewModel.append(localizedError)
            self.onError?(localizedError)
        }
        
        public func webView(_ webView: WKWebView,
                            didFailProvisionalNavigation navigation: WKNavigation!,
                            withError error: Swift.Error)
        {
            let localizedError = Legacy.LError(error: error as NSError)
            self.viewModel.append(localizedError)
            self.onError?(localizedError)
        }
    }
}
