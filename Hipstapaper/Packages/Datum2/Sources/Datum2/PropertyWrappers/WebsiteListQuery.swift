//
//  Created by Jeffrey Bergier on 2022/03/12.
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
public struct WebsiteListQuery: DynamicProperty {
    
    @FetchRequest private var data: FetchedResults<CD_Website>
    
    public init(query: Query, tag: TagListSelection, controller: Controller) {
        var query = query
        let cd_tag: CD_Tag?
        switch tag {
        case .tag(let tag):
            let controller = controller as! CD_Controller
            cd_tag = controller.search([tag.uuid]).first
        case .notATag(let tag):
            cd_tag = nil
            query.isOnlyNotArchived = tag == .unread ? true : false
        }
        _data = FetchRequest<CD_Website>(sortDescriptors: [query.cd_sortDescriptor],
                                         predicate:  query.cd_predicate(cd_tag),
                                         animation: .default)
    }
    
    public var wrappedValue: AnyRandomAccessCollection<FAST_Website> {
        TransformCollection(collection: self.data) { FAST_Website($0) }
            .eraseToAnyRandomAccessCollection()
    }
}
