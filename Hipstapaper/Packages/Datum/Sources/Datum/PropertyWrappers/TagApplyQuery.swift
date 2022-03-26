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
    
    @CDListQuery<CD_Tag, TagApply, Error> private var data: AnyRandomAccessCollection<TagApply>
    @ControllerProperty private var controller
    private let selection: Set<Website.Ident>
    
    public init(selection: Set<Website.Ident>) {
        _data = .init(sort: [CD_Tag.defaultSort], animation: .default) {
            TagApply(tag: $0, selection: selection)
        }
        self.selection = selection
    }
    
    public func update() {
        guard _data.onWrite.value == nil else { return }
         _data.onWrite.value = self.write(_:with:)
    }
    
    public var wrappedValue: AnyRandomAccessCollection<TagApply> {
        self.data
    }
    
    public var projectedValue: AnyRandomAccessCollection<Binding<TagApply>> {
        self.$data
    }
    
    // TODO: Move to controller. Also save changes to tag
    private func write(_ cd: CD_Tag!, with newValue: TagApply!) -> Result<Void, Error> {
        switch newValue.status {
        case .all:
            return self._controller.cdController.addTag(cd, to: self.selection)
        case .none:
            return self._controller.cdController.removeTag(cd, to: self.selection)
        case .some:
            "Invalid change".log()
            return .success(())
        }
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
