//
//  Created by Jeffrey Bergier on 2022/03/13.
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

@propertyWrapper
public struct QueryProperty: DynamicProperty {
    
    // TODO: Change this back to SceneStorage
    @AppStorage("Query") private var query = Query.unreadItems
    
    public init() {}
    
    public var wrappedValue: Query {
        get { self.query }
        nonmutating set {
            self.query = newValue
        }
    }
    
    public var projectedValue: Binding<Query> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}

extension Query: RawRepresentable {
    
    private static var HACK_becauseRRIsNotWorking: Query = .unreadItems
    
    public init?(rawValue: String) {
        do {
            // let data = rawValue.data(using: .utf8) ?? Data()
            // let query = try PropertyListDecoder().decode(Query.self, from: data)
            let query = Query.HACK_becauseRRIsNotWorking
            self.tag = query.tag
            self.sort = query.sort
            self.search = query.search
            self.isOnlyNotArchived = query.isOnlyNotArchived
        } catch {
            error.log()
            return nil
        }
    }
    
    public var rawValue: String {
        do {
            Query.HACK_becauseRRIsNotWorking = self
            return ""
            // TODO: Fix DATUM
            let data = try PropertyListEncoder().encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            error.log()
            return ""
        }
    }
}
