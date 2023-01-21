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
import V3Model

@propertyWrapper
public struct WebsiteQuery: DynamicProperty {
    
    public struct Value {
        public var data: Website?
        public var id: Website.Identifier?
    }
    
    @ErrorStorage private var errors
    @Controller   private var controller
    @CDObjectQuery<CD_Website, Website>(onRead: Website.init(_:)) private var query
    @StateObject private var identifier: SecretBox<Website.Identifier?> = .init(nil)
    
    public init() { }
    
    public var wrappedValue: Value {
        nonmutating set { self.write(newValue) }
        get {
            .init(data: self.query.data,
                  id: self.identifier.value)
        }
    }
    
    public var projectedValue: Binding<Website>? {
        self.$query
    }
    
    private func write(_ newValue: Value) {
        var outputValue = self.query
        if outputValue.onWrite == nil {
            outputValue.onWrite = _controller.cd.write(_:with:)
        }
        if outputValue.onError == nil {
            outputValue.onError = self.errors.append(_:)
        }
        if let newID = newValue.id {
            outputValue.id = URL(string: newID.id)
        } else {
            outputValue.id = nil
        }
        outputValue.data = newValue.data
        self.query = outputValue
    }
}
