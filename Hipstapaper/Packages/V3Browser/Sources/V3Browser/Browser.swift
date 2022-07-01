//
//  Created by Jeffrey Bergier on 2022/07/01.
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
import V3Store
import V3Model

public struct Browser: View {
    
    private let identifier: Website.Identifier
    
    @StateObject private var nav = Nav.newEnvironment()
    
    public init(_ identifier: Website.Identifier) {
        self.identifier = identifier
    }
    
    public var body: some View {
        _Browser(self.identifier)
            .environmentObject(self.nav)
    }
    
}

fileprivate struct _Browser: View {
    
    @Nav private var nav
    @WebsiteQuery private var website
    private let identifier: Website.Identifier
    
    internal init(_ identifier: Website.Identifier) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        NavigationStack {
            Web()
                .modifier(Toolbar(isArchived: self.$website?.isArchived))
        }
        .onLoadChange(of: self.identifier) {
            _website.identifier = $0
        }
        .onLoadChange(of: self.website?.preferredURL) {
            self.nav.shouldLoadURL = $0
        }
    }
}
