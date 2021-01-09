//
//  Created by Jeffrey Bergier on 2021/01/09.
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
import Foundation
import WebKit

public class ViewModel: ObservableObject {
    
    public typealias DoneAction = (Result<Output, Error>) -> Void
    
    public struct Control {
        public var shouldLoad = false
        public var isJSEnabled = false
    }
    
    public struct Output {
        public var title: String = ""
        public var thumbnail: Result<Data, Error>?
        
        // TODO: Remove this hack
        // I can't find a way to map a binding inline in a SwiftUI view
        // so this hack gives me both values
        internal var currentURLString = ""
        public var currentURL: URL? {
            didSet {
                self.currentURLString = self.currentURL?.absoluteString ?? ""
            }
        }
        public var inputURL: URL?
        internal var inputURLString = "" {
            didSet {
                self.inputURL = URL(string: self.inputURLString)
            }
        }
    }
    
    @Published public var control: Control
    @Published public var output: Output
    @Published public var isLoading: Bool = false
    public var thumbnailConfiguration = ThumbnailConfiguration()
    public var doneAction: DoneAction
    public let progress: Progress = .init(totalUnitCount: 100)
    
    @Published internal var formState: Form = .load
    internal var kvo = [NSKeyValueObservation]()
    internal var timer: Timer?
    
    private var formStateToken: AnyCancellable?
        
    public init(prepopulatedURL: URL? = nil,
                doneAction: @escaping DoneAction = { _ in }) {
        var control = Control()
        var output = Output()
        if let prepopulatedURL = prepopulatedURL {
            control.shouldLoad = true
            output.inputURLString = prepopulatedURL.absoluteString
        }
        _control = .init(initialValue: control)
        _output = .init(initialValue: output)
        self.doneAction = doneAction
        
        // For some reason, I have to subscribe to the publishers manually
        // and do this. But oh well.
        self.formStateToken = Publishers.CombineLatest(self.$isLoading, self.$output)
            .sink { [unowned self] isLoading, output in
                if output.currentURL == nil {
                    self.formState = isLoading
                        ? .loading
                        : .load
                } else {
                    self.formState = isLoading
                        ? .loading
                        : .loaded
                }
            }
    }
    
    public func setInputURL(_ inputURL: URL) {
        self.output.inputURLString = inputURL.absoluteString
        self.output.inputURL = inputURL
        self.control.shouldLoad = true
    }
    
    deinit {
        // TODO: Remove this print
        print("DEINIT: Snapshotter ViewModel")
        self.timer?.invalidate()
        self.kvo.forEach({ $0.invalidate() })
    }
}

