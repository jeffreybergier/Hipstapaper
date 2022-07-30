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
public struct TagApplyQuery: DynamicProperty {
    
    @Controller private var controller
    @TagUserListQuery private var data
    @Environment(\.codableErrorResponder) private var errorResponder
    
    @State public var selection: Website.Selection = []
    
    public init() {}
    
    public var wrappedValue: some RandomAccessCollection<TagApply> {
        self.data.map { tag in
            let status = _controller.cd.tagStatus(identifier: tag.id,
                                                  selection: self.selection)
            return .init(tag: tag, status: status)
        }
    }
    
    public var projectedValue: some RandomAccessCollection<Binding<TagApply>> {
        self.data.map { tag in
            Binding {
                let status = _controller.cd.tagStatus(identifier: tag.id,
                                                      selection: self.selection)
                return .init(tag: tag, status: status)
            } set: {
                if let error = _controller.cd.write(tag: $0, selection: self.selection).error {
                    NSLog(String(describing: error))
                    self.errorResponder(.init(error))
                }
            }
        }
    }
}
