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
    
    // TODO: Add queries here
    @FetchRequest private var data: FetchedResults<CD_Website>
    @Environment(\.managedObjectContext) private var context
    
    public init() {
        let sort = NSSortDescriptor(keyPath: \CD_Website.cd_dateCreated, ascending: true)
        let fr = FetchRequest<CD_Website>(sortDescriptors: [sort],
                                          predicate:  nil,
                                          animation: .default)
        _data = fr
    }
    
    public var wrappedValue: AnyRandomAccessCollection<Website> {
        TransformCollection(collection: self.data){ Website($0) }
            .eraseToAnyRandomAccessCollection()
    }
}
