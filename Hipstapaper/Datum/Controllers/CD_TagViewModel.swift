//
//  Created by Jeffrey Bergier on 2021/03/12.
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

import Combine
import SwiftUI
import Umbrella

internal class CD_TagViewModel: TagViewModel {
    
    var getStorage: TagViewModelGetStorage?
    var setStorage: TagViewModelSetStorage?
    
    lazy var fixed: AnyRandomAccessCollection<TagViewModelOutput> = {
        let all = Query.Filter.allCases
        assert(all.count == 2)
        return all.map { [weak self] filter -> TagViewModelOutput in
            let binding = Binding<Bool>(
                get: { filter.uriRepresentation == self?.getStorage?() },
                set: { if $0 { self?.setStorage?(filter.uriRepresentation) } }
            )
            return (tag: AnyElementObserver(StaticElement(AnyTag(filter))), binding: binding)
        }.eraseToAnyRandomAccessCollection()
    }()
    private var _data: AnyRandomAccessCollection<TagViewModelOutput>?
    var data: AnyRandomAccessCollection<TagViewModelOutput> {
        if let data = _data { return data }
        _data = self.input.data.lazy.map { [weak self] obs -> TagViewModelOutput in
            let tag = obs.value.wrappedValue as! CD_Tag
            let binding = Binding<Bool>(
                get: { tag.objectID.uriRepresentation() == self?.getStorage?() },
                set: { if $0 { self?.setStorage?(tag.objectID.uriRepresentation()) } }
            )
            return (tag: obs, binding: binding)
        }.eraseToAnyRandomAccessCollection()
        return _data!
    }
    
    typealias Input = FetchedResultsControllerListObserver<AnyElementObserver<AnyTag>, CD_Tag>
    private var input: Input
    private var token: AnyCancellable?
    init(_ input: Input) {
        self.input = input
        self.token = input.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
            self?._data = nil
        }
    }
}
