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

extension URL {
    // TODO: Move out of host app and into style
    var prettyValueHost: String? {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        guard let host = components?.host else { return nil }
        return host.replacing(#/www\./#, maxReplacements: 1, with: { _ in "" })
    }
}

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
        // TODO: Improve by using setPropertyList?
        self.setString(url.absoluteString, forType: .URL)
    }
}
#else
extension UIPasteboard {
    fileprivate func set(title: String?, url: URL) {
        guard
            let stringKey = UIPasteboard.typeListString[0] as? String,
            let urlKey = UIPasteboard.typeListURL[0] as? String
        else { return }
        let titleDict = title.map { [stringKey: $0] } ?? [:]
        let urlDict = [urlKey: url]
        self.setItems([titleDict, urlDict])
    }
}
#endif
