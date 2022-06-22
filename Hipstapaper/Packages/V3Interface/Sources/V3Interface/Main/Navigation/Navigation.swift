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
import V3Model

internal struct Navigation: Codable {
    internal var sidebar: Sidebar = .init()
    internal var detail: Detail = .init()
}

extension Navigation {
    internal struct Sidebar: Codable {
        internal var selectedTag: Tag.Selection.Element? = .default
        internal var isTagAdd: Tag.Identifier?
        internal var isTagsEdit: Tag.Selection = []
        internal var isWebsiteAdd: Website.Selection.Element?
    }
    internal struct Detail: Codable {
        internal var selectedWebsites = Set<Website.Identifier>()
    }
}

@propertyWrapper
internal struct Nav: DynamicProperty {
    
    @SceneStorage("com.hipstapaper.nav") private var data: String?
    
    var wrappedValue: Navigation {
        get { self.data?.decodeNavigation ?? .init() }
        nonmutating set { self.data = newValue.encodeString }
    }
    
    var projectedValue: Binding<Navigation> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    
}

extension String {
    fileprivate var decodeNavigation: Navigation? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return try? PropertyListDecoder().decode(Navigation.self, from: data)
    }
}

extension Navigation {
    fileprivate var encodeString: String? {
        guard let data = try? PropertyListEncoder().encode(self) else { return nil }
        return data.base64EncodedString()
    }
}
