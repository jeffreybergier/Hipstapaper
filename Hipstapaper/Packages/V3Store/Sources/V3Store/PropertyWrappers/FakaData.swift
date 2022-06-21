//
//  Created by Jeffrey Bergier on 2022/06/21.
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

#if DEBUG

import Foundation
import SwiftUI
import Umbrella
import V3Model

internal let tagEnvironment = BlackBox(fakeTags, isObservingValue: true)

fileprivate let fakeTags: [Tag] = [
        Tag(id: .init(rawValue: "tag01"), name: "Cool Stuff", websitesCount: 400000),
        Tag(id: .init(rawValue: "tag02"), name: "Bad Things", websitesCount: 2),
        Tag(id: .init(rawValue: "tag03"), name: "👨‍👩‍👧‍👧", websitesCount: -80),
        Tag(id: .init(rawValue: "tag04"), name: "日本語", websitesCount: 200),
        Tag(id: .init(rawValue: "tag05"), name: "Accounts", websitesCount: 30),
        Tag(id: .init(rawValue: "tag06"), name: "No Count", websitesCount: nil),
        Tag(id: .init(rawValue: "tag07"), name: nil, websitesCount: 0101),
    ]

extension BlackBox where Value: RandomAccessCollection & MutableCollection, Value.Index == Int {
    internal var projectedValue: Array<Binding<Value.Element>> {
        self.value.enumerated().map { (index, item) in
            Binding {
                item
            } set: {
                self.value[index] = $0
            }
        }
    }
}

#endif
