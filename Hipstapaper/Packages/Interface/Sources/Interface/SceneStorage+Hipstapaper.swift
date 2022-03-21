//
//  Created by Jeffrey Bergier on 2021/03/11.
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
import Datum

@propertyWrapper
struct SceneSearch: DynamicProperty {
    @SceneStorage("query.search") private var search = ""
    var wrappedValue: String {
        get { self.search }
        nonmutating set { self.search = newValue }
    }
    var projectedValue: Binding<String> {
        self.$search
    }
}

@propertyWrapper
struct SceneFilter: DynamicProperty {
    @SceneStorage("query.filter") private var filter = true
    var wrappedValue: Query.Filter {
        get { .init(boolValue: self.filter) }
        nonmutating set { self.filter = newValue.boolValue }
    }
}

@propertyWrapper
struct SceneSort: DynamicProperty {
    @SceneStorage("query.sort") private var sort = Sort.default
    var wrappedValue: Sort {
        get { self.sort }
        nonmutating set { self.sort = newValue }
    }
    var projectedValue: Binding<Sort?> {
        Binding(
            get: { self.sort },
            set: { self.sort = $0 ?? .default }
        )
    }
}

@propertyWrapper
struct SceneTag: DynamicProperty {
    
    private static let defaultURL = Query.Filter.unarchived.uri
    private static let invalidURL = URL(string: "hipstapaper://not.a.url.com")!
    
    @SceneStorage("query.tag") private var selectedTagURL = SceneTag.defaultURL
    
    var wrappedValue: URL? {
        get { self.selectedTagURL }
        nonmutating set { self.selectedTagURL = newValue ?? SceneTag.invalidURL }
    }
    
    var projectedValue: Binding<URL?> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 ?? SceneTag.invalidURL }
        )
    }
}
