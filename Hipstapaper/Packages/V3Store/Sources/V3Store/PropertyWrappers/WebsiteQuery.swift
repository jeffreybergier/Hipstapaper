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
    
    @Controller private var controller
    @CDObjectQuery<CD_Website, Website, Error>(onRead: Website.init(_:)) private var object: Website?
    
    @Environment(\.codableErrorResponder) private var errorResponder
    
    public init() { }
    
    public func setIdentifier(_ newValue: Website.Identifier?) {
        if
            let newValue,
            let url = URL(string: newValue.id)
        {
            _object.setObjectIDURL(url)
        } else {
            _object.setObjectIDURL(nil)
        }
    }
    
    public var wrappedValue: Website? {
        get { self.object }
        nonmutating set { self.object = newValue }
    }
    
    public var projectedValue: Binding<Website>? {
        self.$object
    }
    
    private let needsUpdate = BlackBox(true, isObservingValue: false)
    public func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        _object.setOnWrite(_controller.cd.writeOpt(_:with:))
        _object.setOnError { error in
            NSLog(String(describing: error))
            self.errorResponder(.init(error))
        }
    }
}
