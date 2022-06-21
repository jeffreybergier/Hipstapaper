//
//  Created by Jeffrey Bergier on 2022/06/20.
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
public struct WebsiteListQuery: DynamicProperty {
    
    @State public var query: Query = .systemUnread
    @State public var identifier: Tag.Identifier? = nil
    
    // TODO: Hook up core data
    @ObservedObject private var sites1 = site1Environment
    @ObservedObject private var sites2 = site2Environment
    
    public init() {}
    
    public var wrappedValue: some RandomAccessCollection<Website> {
        switch delete_which {
        case 0:
            return sites1.value + sites2.value
        case 1:
            return sites1.value
        case 2:
            return sites2.value
        default:
            fatalError()
        }
    }
    
    public var projectedValue: some RandomAccessCollection<Binding<Website>> {
        switch delete_which {
        case 0:
            return sites1.projectedValue + sites2.projectedValue
        case 1:
            return sites1.projectedValue
        case 2:
            return sites2.projectedValue
        default:
            fatalError()
        }
    }
    
    private var delete_which: Int {
        guard
            let tag = identifier,
            tag != Tag.Identifier.systemUnread,
            tag != Tag.Identifier.systemAll
        else {
            return 0
        }
        if tag.rawValue == tagEnvironment.value.first?.id.rawValue {
            return 1
        } else {
            return 2
        }
    }
}
