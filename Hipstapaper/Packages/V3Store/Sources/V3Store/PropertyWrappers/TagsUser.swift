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
import V3Model

@propertyWrapper
public struct TagsUser: DynamicProperty {
    
    // TODO: Hook up core data
    
    public init() {}
    
    public var wrappedValue: some RandomAccessCollection<Tag> {
        fakeData
    }
}

#if DEBUG
internal let fakeData: [Tag] = [
        Tag(id: .init(rawValue: "coredata://fake1"), name: "Cool Stuff", websitesCount: 400000),
        Tag(id: .init(rawValue: "coredata://fake2"), name: "Bad Things", websitesCount: 2),
        Tag(id: .init(rawValue: "coredata://fake3"), name: "👨‍👩‍👧‍👧", websitesCount: -80),
        Tag(id: .init(rawValue: "coredata://fake4"), name: "日本語", websitesCount: 200),
        Tag(id: .init(rawValue: "coredata://fake5"), name: "Accounts", websitesCount: 30),
        Tag(id: .init(rawValue: "coredata://fake6"), name: "No Count", websitesCount: nil),
        Tag(id: .init(rawValue: "coredata://fake7"), name: nil, websitesCount: 0101),
    ]
#endif
