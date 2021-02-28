//
//  Created by Jeffrey Bergier on 2021/01/09.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
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

import Combine
import WebKit
import Umbrella

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
        log.verbose()
        self.timer?.invalidate()
        self.kvo.forEach({ $0.invalidate() })
    }
}

extension ViewModel.Output: Codable {
    public enum CodingKeys: String, CodingKey {
        case title
        case thumbnail
        case currentURL
        case inputURL
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try values.decode(String.self, forKey: .title)
        self.inputURL = try values.decode(Optional<URL>.self, forKey: .inputURL)
        self.currentURL = try values.decode(Optional<URL>.self, forKey: .currentURL)
        let data = try values.decode(Optional<Data>.self, forKey: .thumbnail)
        if let data = data {
            self.thumbnail = .success(data)
        } else {
            self.thumbnail = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.inputURL, forKey: .inputURL)
        try container.encode(self.currentURL, forKey: .currentURL)
        try container.encode(self.thumbnail?.value, forKey: .thumbnail)
    }
}
