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

public typealias TagViewModelOutput = (tag: AnyElementObserver<AnyTag>, binding: Binding<Bool>)
public typealias TagViewModelGetStorage = () -> URL?
public typealias TagViewModelSetStorage = (URL) -> Void

public protocol TagViewModel: ObservableObject {
    var getStorage: TagViewModelGetStorage? { get set }
    var setStorage: TagViewModelSetStorage? { get set }
    var fixed: AnyRandomAccessCollection<TagViewModelOutput> { get }
    var data: AnyRandomAccessCollection<TagViewModelOutput> { get }
}

public class AnyTagViewModel: TagViewModel {
    
    public let objectWillChange: ObservableObjectPublisher
    
    public var getStorage: TagViewModelGetStorage? {
        get { _get_getStorage() }
        set { _set_getStorage(newValue) }
    }
    public var setStorage: TagViewModelSetStorage? {
        get { _get_setStorage() }
        set { _set_setStorage(newValue) }
    }
    public var fixed: AnyRandomAccessCollection<TagViewModelOutput> { _fixed() }
    public var data: AnyRandomAccessCollection<TagViewModelOutput> { _data() }
    
    private var _get_getStorage: () -> TagViewModelGetStorage?
    private var _set_getStorage: (TagViewModelGetStorage?) -> Void
    private var _get_setStorage: () -> TagViewModelSetStorage?
    private var _set_setStorage: (TagViewModelSetStorage?) -> Void
    private var _fixed: () -> AnyRandomAccessCollection<TagViewModelOutput>
    private var _data: () -> AnyRandomAccessCollection<TagViewModelOutput>
    
    public init<T: TagViewModel>(_ viewModel: T)
          where T.ObjectWillChangePublisher == ObservableObjectPublisher
    {
        _get_getStorage = { viewModel.getStorage }
        _set_getStorage = { viewModel.getStorage = $0 }
        _get_setStorage = { viewModel.setStorage }
        _set_setStorage = { viewModel.setStorage = $0 }
        _fixed = { viewModel.fixed }
        _data = { viewModel.data }
        self.objectWillChange = viewModel.objectWillChange
    }
}
