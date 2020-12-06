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

public struct Snapshotter: View {
    
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
        var formState: Form.Which {
            switch (self.input.shouldLoad, self.output.isLoading) {
            case (false, _):
                return .load
            case (true, true):
                return .loading
            case (true, false):
                return .loaded
            }
        }
        
        init(_ input: Input) {
            var wvInput = WebView.Input()
            if let url = input.loadURL {
                wvInput.shouldLoad = true
                wvInput.originalURLString = url.absoluteString
            }
            self.input = wvInput
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    
    public init(_ input: Input = .init(), completion: @escaping (Result<Output, Error>) -> Void) {
        _viewModel = ObservedObject(wrappedValue: ViewModel(input))
    }
    
    public var body: some View {
        VStack {
            Form(viewModel: self.viewModel)
                .padding()
            ZStack {
                WebView(input: self.$viewModel.input,
                        output: self.viewModel.output)
                WebThumbnail(viewModel: self.viewModel)
            }
            .frame(width: 300, height: 300)
        }
    }
}

internal struct WebThumbnail: View {
    
    @ObservedObject var viewModel: Snapshotter.ViewModel

    var body: some View {
        switch self.viewModel.formState {
        case .load:
            return AnyView(Image(systemName: "globe"))
        case .loading:
            return AnyView(Spacer().hidden()) // show nothing
        case .loaded:
            if let data = self.viewModel.output.thumbnail?.value {
                return AnyView(Thumbnail(data))
            } else {
                return AnyView(Image(systemName: "exclamationmark.icloud"))
            }
        }
    }
    
}
