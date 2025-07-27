//
//  Created by Jeffrey Bergier on 2022/06/17.
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
import Umbrella

internal enum JSBPasteboard {
    internal static func set(title: String?, url: URL) {
        #if os(macOS)
        NSPasteboard.general.set(title: title, url: url)
        #else
        UIPasteboard.general.set(title: title, url: url)
        #endif
    }
}

#if os(macOS)
extension NSPasteboard {
    fileprivate func set(title: String?, url: URL) {
        self.declareTypes([.URL], owner: nil)
        let success = self.setString(url.absoluteString, forType: .URL)
        assert(success, "Pasteboard Error")
    }
}
#else
import UniformTypeIdentifiers
extension UIPasteboard {
    fileprivate func set(title: String?, url: URL) {
        let stringKey = UTType.plainText.description
        let urlKey = UTType.url.description
        let titleDict = title.map { [stringKey: $0] } ?? [:]
        let urlDict = [urlKey: url]
        self.setItems([titleDict, urlDict])
    }
}
#endif
