//
//  Created by Jeffrey Bergier on 2022/12/22.
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

import Foundation

extension URL {
    internal var prettyValueHost: String? {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        guard let host = components?.host else { return nil }
        return host.replacing(#/www\./#, maxReplacements: 1, with: { _ in "" })
    }
    internal var prettyValue: String? {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        guard let _host = components?.host else { return nil }
        // TODO: This could still be improved
        // I basically want to check the host from the end for all known TLD's
        // and then just show the first part of the domain. To be clearer...
        // "act.net.www.companyname.co.jp" would show "companyname.co.jp"
        // I might be able to shortcut it by doing components separated by "."
        // then delete any component equal to "www" and then keep the last 3 components
        let host = _host.replacing(#/www\./#, maxReplacements: 1, with: { _ in "" })
        guard let path = components?.path else { return host }
        return host+path
    }
}
