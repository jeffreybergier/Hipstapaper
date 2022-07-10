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
public struct TagUserListQuery: DynamicProperty {
    
    @CDListQuery<CD_Tag, Tag, Error> private var data: AnyRandomAccessCollection<Tag>
    @EnvironmentObject private var controller: BlackBox<ControllerProtocol?>
    
    // TODO: Figure out how to connect this
    @State public var filter: Set<Tag.Identifier> = []
    
    public init() {
        _data = .init(sort: [], predicate: NSPredicate(value: true), animation: .default, onWrite: nil) {
            Tag($0)
        }
    }
    
    public func update() {
        if _data.onWrite.value == nil {
            _data.onWrite.value = { [weak controller] object, value in
                let controller = controller?.value as? CD_Controller
                return controller?.write(object, with: value) ?? .failure(.write)
            }
        }
    }
    
    public var wrappedValue: some RandomAccessCollection<Tag> {
        self.data
    }
    
    public var projectedValue: some RandomAccessCollection<Binding<Tag>> {
        self.$data
    }
}
