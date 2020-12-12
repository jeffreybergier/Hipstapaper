//
//  Created by Jeffrey Bergier on 2020/12/05.
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
import Combine
import Stylize

public struct Snapshotter: View {
    
    public typealias Completion = (Result<Output, Error>) -> Void
    
    public struct Input {
        var loadURL: URL?
        public init(loadURL: URL? = nil) {
            self.loadURL = loadURL
        }
    }
    
    public struct Output: Codable {
        var originalURL: URL
        var resolvedURL: URL
        var title: String
        var thumbnail: Data?
        var date: Date = Date()
    }
    
    class ViewModel: ObservableObject {
        @Published var input = WebView.Input()
        @Published var output = WebView.Output()
        @Published var formState: Form = .load

        private var token: AnyCancellable?
        
        init(_ input: Input) {
            var wvInput = WebView.Input()
            if let url = input.loadURL {
                wvInput.shouldLoad = true
                wvInput.originalURLString = url.absoluteString
            }
            self.input = wvInput
            
            // For some reason, I have to subscribe to the publishers manually
            // and do this. But oh well.
            self.token = Publishers.CombineLatest3(self.$input,
                                                   self.output.$isLoading,
                                                   self.output.$thumbnail)
                .sink { [unowned self] input, isLoading, _ in
                    switch (input.shouldLoad, isLoading) {
                    case (false, _):
                        self.formState = .load
                    case (true, true):
                        self.formState = .loading
                    case (true, false):
                        self.formState = .loaded
                    }
                }
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    let completion: Completion
    
    public init(_ input: Input = .init(), completion: @escaping Completion) {
        _viewModel = ObservedObject(wrappedValue: ViewModel(input))
        self.completion = completion
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            SnapshotToolbar(
                output: self.viewModel.output,
                cancel: { self.completion(.failure(.userCancelled)) },
                confirm: {
                    guard
                        let originalURL = URL(string: self.viewModel.input.originalURLString),
                        let resolvedURL = URL(string: self.viewModel.output.resolvedURLString)
                    else {
                        self.completion(.failure(.convertURL))
                        return
                    }
                    self.completion(.success(
                        Snapshotter.Output(originalURL: originalURL,
                                           resolvedURL: resolvedURL,
                                           title: self.viewModel.output.title,
                                           thumbnail: self.viewModel.output.thumbnail?.value)
                    ))
                }
            )
            FormSwitcher(viewModel: self.viewModel)
                .padding()
            Spacer()
            ZStack {
                WebView(input: self.$viewModel.input,
                        output: self.viewModel.output)
                WebThumbnail(viewModel: self.viewModel)
            }
            .frame(width: 300, height: 300)
            .cornerRadius_medium
            .padding()
        }
    }
}

internal struct WebThumbnail: View {
    
    @ObservedObject var viewModel: Snapshotter.ViewModel

    // TODO: Fix this
    var body: some View {
        switch self.viewModel.formState {
        case .load:
            return AnyView(Thumbnail.SystemName("globe"))
        case .loading, .loaded:
            if let data = self.viewModel.output.thumbnail?.value {
                return AnyView(Thumbnail.Image(data))
            } else {
                return AnyView(Thumbnail.SystemName("exclamationmark.icloud"))
            }
        }
    }
}
