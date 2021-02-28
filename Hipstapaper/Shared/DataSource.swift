//
//  Created by Jeffrey Bergier on 2021/02/04.
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

import Umbrella
import Datum

protocol DataSource: ObservableObject {
    associatedtype Observer: ListObserver where Observer.Collection.Element: Hashable & Identifiable
    
    var controller: Controller { get }
    /// Should be @Published
    var observer: Observer? { get }
    /// Computed property that `{ observer?.data ?? .empty }`
    var data: Observer.Collection { get }
    
    /// Causes the observer to be created and start observing.
    /// Pass errorQ if you want errors to be captured
    func activate(_ errorQ: ErrorQueue?)
    /// Causes the observer to be deallocated and no longer be observed
    func deactivate()
}
