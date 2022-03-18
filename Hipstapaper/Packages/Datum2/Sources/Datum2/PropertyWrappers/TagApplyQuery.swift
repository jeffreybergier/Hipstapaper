//
//  Created by Jeffrey Bergier on 2022/03/18.
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

@propertyWrapper
public struct TagApplyQuery: DynamicProperty {
    
    @FetchRequest private var data: FetchedResults<CD_Tag>
    
    private let selection: Set<Website.Ident>
    
    public init(selection: Set<Website.Ident>) {
        let sort = NSSortDescriptor(keyPath: \CD_Tag.cd_name, ascending: true)
        _data = FetchRequest<CD_Tag>(sortDescriptors: [sort],
                                     predicate:  nil,
                                     animation: .default)
        self.selection = selection
    }
    
    public var wrappedValue: AnyRandomAccessCollection<TagApply> {
        TransformCollection(collection: self.data) {
            TagApply(tag: $0, selection: self.selection)
        }
        .eraseToAnyRandomAccessCollection()
    }
}

extension TagApply {
    fileprivate init(tag: CD_Tag, selection rhs: Set<Website.Ident>) {
        let _lhs = tag.cd_websites
            .compactMap { $0 as? CD_Website }
            .map { Website.Ident($0.objectID) }
        let lhs = Set(_lhs)
        let compare = lhs.subtracting(rhs)
        switch compare.count {
        case 0:
            self.status = .none
        case lhs.count:
            self.status = .all
        default:
            self.status = .some
        }
        
        self.tag = .init(tag)
    }
}
