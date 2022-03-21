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
    
    @ErrorQueue private var errorQ
    @FetchRequest private var data: FetchedResults<CD_Tag>
    @EnvironmentObject private var _controller: BlackBox<Controller?>
    private var controller: CD_Controller {
        _controller.value as! CD_Controller
    }
    
    private let selection: Set<Website.Ident>
    
    public init(selection: Set<Website.Ident>) {
        _data = FetchRequest<CD_Tag>(sortDescriptors: [CD_Tag.defaultSort],
                                     predicate:  nil,
                                     animation: .default)
        self.selection = selection
    }
    
    public var wrappedValue: AnyRandomAccessCollection<Binding<TagApply>> {
        TransformCollection(collection: self.data) { cd_tag in
            Binding {
                TagApply(tag: cd_tag, selection: self.selection)
            } set: { newValue in
                switch newValue.status {
                case .all:
                    self.controller.addTag(cd_tag, to: self.selection)
                        .error.map {
                            self.errorQ = $0
                            log.error($0)
                        }
                case .none:
                    self.controller.removeTag(cd_tag, to: self.selection)
                        .error.map {
                            self.errorQ = $0
                            log.error($0)
                        }
                case .some:
                    "Invalid change".log()
                }
            }
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
        case lhs.count-rhs.count:
            self.status = .all
        case lhs.count:
            self.status = .none
        default:
            self.status = .some
        }
        
        self.tag = .init(tag)
    }
}
