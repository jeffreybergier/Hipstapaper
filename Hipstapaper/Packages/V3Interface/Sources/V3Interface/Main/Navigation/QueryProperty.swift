//
//  Created by Jeffrey Bergier on 2022/06/20.
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

@propertyWrapper
internal struct QueryProperty: DynamicProperty {
    
    @SceneStorage("com.hipstapaper.query") private var data: String?
    
    var wrappedValue: Query {
        get { self.data?.decodeQuery ?? .unreadItems }
        nonmutating set { self.data = newValue.encodeString }
    }
    
    var projectedValue: Binding<Query> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    
}

extension String {
    fileprivate var decodeQuery: Query? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return try? PropertyListDecoder().decode(Query.self, from: data)
    }
}

extension Query {
    fileprivate var encodeString: String? {
        guard let data = try? PropertyListEncoder().encode(self) else { return nil }
        return data.base64EncodedString()
    }
}
