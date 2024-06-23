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

@MainActor
@propertyWrapper
public struct TagApplyQuery: DynamicProperty {
    
    @ErrorStorage private var errors
    @Controller   private var controller
    
    // TODO: Restore the use of `TagUserListQuery`
    // For some reason, in Release builds, there is a compiler error in Xcode 14.3
    // @TagUserListQuery private var data
    @FetchRequest(entity: CD_Tag.entity(),
                  sortDescriptors: [NSSortDescriptor(CD_Tag.defaultSort)],
                  predicate: .init(value: true),
                  animation: .default)
    private var tags: FetchedResults<CD_Tag>
    
    @State public var selection: Website.Selection = []
    
    public init() {}
    
    public var wrappedValue: some RandomAccessCollection<TagApply> {
        return self.tags.lazy.map(self.valueGenerator(_:))
    }
    
    public var projectedValue: some RandomAccessCollection<Binding<TagApply>> {
        return self.tags.map { tag in
            Binding {
                self.valueGenerator(tag)
            } set: {
                let result = _controller.cd.write(tag: $0, selection: self.selection)
                guard let error = result.error else { return }
                NSLog(String(describing: error))
                self.errors.append(error)
            }
        }
    }
    
    private func valueGenerator(_ tag: CD_Tag) -> TagApply {
        let identifier = Tag.Identifier(tag.objectID)
        let status = _controller.cd.tagStatus(identifier: identifier,
                                              selection: self.selection)
        return .init(identifier: identifier, status: status)
    }
}
