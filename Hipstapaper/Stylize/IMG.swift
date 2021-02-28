//
//  Created by Jeffrey Bergier on 2021/01/12.
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

import SwiftUI

extension STZ.ICN {
    /// Returns a thumbnail image of icon
    /// If data can be converted to image, it returns that instead
    // TODO: Make this take a Result<Data, LocalizedError>
    @ViewBuilder public func thumbnail(_ data: Data? = nil) -> some View {
        if let image = data?.imageValue {
            image
                .modifier(STZ.CRN.Small.apply())
                .aspectRatio(1, contentMode: .fit)
        } else {
            self
                .modifier(Thumbnail())
                .modifier(STZ.CRN.Small.apply())
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

fileprivate struct Thumbnail: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        ZStack {
            STZ.CLR.Thumbnail.Background.view()
            content
                .modifier(STZ.CLR.Thumbnail.Icon.foreground())
        }
    }
}

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Data {
    fileprivate var imageValue: Image? {
        #if os(macOS)
        guard let image = NSImage(data: self) else { return nil }
        return Image(nsImage: image).resizable()
        #else
        guard let image = UIImage(data: self) else { return nil }
        return Image(uiImage: image).resizable()
        #endif
    }
}
