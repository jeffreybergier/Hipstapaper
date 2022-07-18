//
//  Created by Jeffrey Bergier on 2022/06/19.
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

import SwiftUI

internal struct FontMonospacedDigit: ViewModifier {
    internal func body(content: Content) -> some View {
        content
            .monospacedDigit()
    }
}

internal struct ThumbnailImage: View {
    @Environment(\.colorScheme) private var scheme
    private let data: Data?
    internal init(_ data: Data?) {
        self.data = data
    }
    internal var body: some View {
        ZStack {
            Color.lightGray(self.scheme)
            Image(systemName: SystemImage.photo.rawValue)
            Image(data: self.data)?.resizable()
        }
    }
}

internal struct WebThumbnailImage<Background: View>: View {
    private let data: Data?
    private let web: () -> Background
    internal init(_ data: Data?, web: @escaping () -> Background) {
        self.data = data
        self.web = web
    }
    internal var body: some View {
        ZStack {
            self.web()
            ThumbnailImage(self.data)
        }
    }
}
